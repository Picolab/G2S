ruleset org.sovrin.agent {
  meta {
    use module org.sovrin.agent_message alias a_msg
    use module org.sovrin.agent.ui alias invite
    use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.visual_params alias vp
    use module webfinger alias wf
    shares __testing, html, ui, getEndpoint, connections, pendingConnections,
      get_last_http_response, get_routing_response
    provides connections, ui
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "connections", "args": [ "label" ] }
      , { "name": "getEndpoint", "args" : ["my_did", "endpoint"] }
      , { "name": "pendingConnections" }
      ] , "events":
      [ { "domain": "webfinger", "type": "webfinger_wanted" }
      , { "domain": "sovrin", "type": "update_endpoint", "attrs" : ["my_did", "their_host"] }
      , { "domain": "agent", "type": "pending_connections_cleanup_requested" }
      , { "domain": "agent", "type": "connections_cleanup_requested" }
      ]
    }
    html = function(c_i){
      invite:html(c_i)
    }
    ui = function(){
      connections = ent:connections
        .values()
        .sort(function(a,b){
          a{"created"} cmp b{"created"}
        });
      {
        "name": ent:label,
        "connections": connections.length() => connections | null,
        "invitation": invitation(),
        "wf": ent:webfinger,
      }
    }
    invitation = function(){
      uKR = wrangler:channel("agent");
      eci = uKR{"id"};
      im = a_msg:connInviteMap(
        null, // @id
        ent:label,
        uKR{["sovrin","indyPublic"]},
        a_msg:localServiceEndpoint(eci)
      );
      ep = <<#{meta:host}/sky/cloud/#{eci}/#{meta:rid}/html.html>>;
      ep + "?c_i=" + math:base64encode(im.encode())
    }
    //Function added by Jace, Beto, and Michael to update the connection's endpoints
    getEndpoint = function(my_did, endpoint) {
      endpoint + ent:connections.filter(function(v) {
        v{"my_did"} == my_did
      }).values().map(function(x) {
        x{"their_endpoint"}
      })[0].extract(re#(/sky/event/.*)#).head()//.split("/").slice(3, 8).join("/")
    }
    connections = function(label) {
      matching = function(x){x{"label"}==label};
      label => ent:connections.filter(matching).values().head()
             | ent:connections
    }
    pendingConnections = function(){
      ent:pending_conn
    }
    get_last_http_response = function(){
      ent:last_http_response
    }
    get_routing_response = function(){
      ent:routing_response
    }
  }
//
// on ruleset_added
//
  rule on_installation {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      label = event:attr("label")
        || event:attr("rs_attrs"){"label"}
    }
    if wrangler:channel("agent").isnull() then
      wrangler:createChannel(meta:picoId,"agent","sovrin")
    always {
      ent:label := label || wrangler:name();
      ent:connections := {};
      raise wrangler event "ruleset_needs_cleanup_period" attributes {
        "domain": meta:rid
      }
    }
  }
  rule webfinger_check {
    select when webfinger webfinger_wanted
    fired {
      ent:webfinger := wf:webfinger(wrangler:name())
    }
  }
  rule check_label {
    select when agent check_state
    pre {
      bad = ent:label.isnull() || typeof(ent:label) != "String" || ent:label == ""
    }
    if bad then noop()
    fired {
      ent:label := wrangler:name()
    }
  }
//
// send ssi_agent_wire message
//
  rule send_ssi_agent_wire_message {
    select when sovrin new_ssi_agent_wire_message
    pre {
      se = event:attr("serviceEndpoint")
      pm = event:attr("packedMessage")
    }
    http:post(
      se,
      body=pm,
      headers={"content-type":"application/ssi-agent-wire"},
      autosend = {"eci": meta:eci, "domain": "http", "type": "post"}
    )
  }
  rule save_last_http_response {
    select when http post
    fired {
      ent:last_http_response := event:attrs
    }
  }
  rule record_eci_not_found_error {
    select when http post status_code re#404#
    pre {
      content = event:attr("content").decode()
      eci = content{"error"}.extract(re#ECI not found: (.+)#).head()
      conn = ent:connections.filter(function(c){
        c{"their_did"} == eci
      })
      vk = conn.keys().head()
    }
    if eci && conn then noop()
    fired {
      ent:connections{[vk,"error"]} := "ECI not found: "+eci
    }
  }
//
// accept invitation
//
  rule accept_invitation {
    select when sovrin new_invitation
      url re#(http.+[?].*((c_i=)|(d_m=)).+)# setting(url)
    pre {
      qs = url.split("?").tail().join("?")
      args = qs.split("&")
        .map(function(x){x.split("=")})
        .collect(function(x){x[0]})
        .map(function(x){x[0][1]})
      c_i = args{"c_i"} || args{"d_m"}
      im = math:base64decode(c_i).decode()
      their_label = im{"label"}
      need_router_connection = event:attr("need_router_connection")
    }
    if im && their_label then
      wrangler:createChannel(meta:picoId,their_label,"connection")
        setting(channel)
    fired {
      raise agent event "check_state" attributes {};
      raise edge event "need_router_connection"
        attributes {
          "invitation": im,
          "channel": channel,
          "label": their_label,
          "txnId": meta:txnId,
          "sovrin_event": "invitation_accepted",
        } if need_router_connection;
      raise sovrin event "invitation_accepted"
        attributes {
          "invitation": im,
          "channel": channel
        } if need_router_connection.isnull()
    }
  }
//
// initiate connections request
//
  rule initiate_connection_request {
    select when sovrin invitation_accepted
    pre {
      im = event:attr("invitation")
      chann = event:attr("channel")
      my_did = chann{"id"}
      my_vk = chann{["sovrin","indyPublic"]}
      ri = event:attr("routing").klog("routing information")
      rks = ri => ri{"their_routing"} | null
      endpoint = ri => ri{"endpoint"} | a_msg:localServiceEndpoint(my_did)
      rm = a_msg:connReqMap(ent:label,my_did,my_vk,endpoint,rks,im{"@id"})
        .klog("connections request")
      reqURL = im{"serviceEndpoint"}
      pc = {
        "label": im{"label"},
        "my_did": my_did,
        "@id": rm{"@id"},
        "my_did": my_did,
        "their_vk": im{"recipientKeys"}.head(),
        "their_routing": im{"routingKeys"}.defaultsTo([]),
      }
      packedBody = a_msg:packMsg(pc,rm)
    }
    fired {
      ent:pending_conn := ent:pending_conn.defaultsTo([]).append(pc);
      raise sovrin event "new_ssi_agent_wire_message" attributes {
        "serviceEndpoint": reqURL, "packedMessage": packedBody
      }
    }
  }
//
// receive messages
//
  rule route_new_message {
    select when sovrin new_message protected re#(.+)# setting(protected)
    pre {
      outer = math:base64decode(protected).decode()
      kids = outer{"recipients"}
        .map(function(x){x{["header","kid"]}})
      my_vk = wrangler:channel(meta:eci){["sovrin","indyPublic"]}
      sanity = (kids >< my_vk)
        .klog("sanity")
      all = indy:unpack(event:attrs,meta:eci)
      msg = all{"message"}.decode()
      event_type = a_msg:specToEventType(msg{"@type"})
    }
    if event_type then
      send_directive("message routed",{"event_type":event_type})
    fired {
      raise agent event "check_state" attributes {};
      raise sovrin event event_type attributes
        all.put("message",msg)
           .put("need_router_connection",event:attr("need_router_connection"))
    }
  }
//
// connections/request
//
  rule handle_connections_request {
    select when sovrin connections_request
    pre {
      msg = event:attr("message")
      their_label = msg{"label"}
      need_router_connection = event:attr("need_router_connection")
    }
    if their_label then
      wrangler:createChannel(meta:picoId,their_label,"connection")
        setting(channel)
    fired {
      raise edge event "need_router_connection"
        attributes {
          "message": msg,
          "channel": channel,
          "label": their_label,
          "txnId": meta:txnId,
          "sovrin_event": "connections_request_accepted",
        } if need_router_connection;
      raise sovrin event "connections_request_accepted"
        attributes {
          "message": msg,
          "channel": channel,
        } if need_router_connection.isnull()
    }
  }
  rule having_router_connection_pursue_connection {
    select when edge new_router_connection_recorded
      where event:attr("txnId") == meta:txnId
    fired {
      ent:routing_response := event:attrs;
      raise sovrin event event:attr("sovrin_event")
        attributes event:attrs
    }
  }
  rule initiate_connections_response {
    select when sovrin connections_request_accepted
    pre {
      msg = event:attr("message")
      req_id = msg{"@id"}
      connection = msg{"connection"}
      their_did = connection{"DID"}
      publicKeys = connection{["DIDDoc","publicKey"]}
        .map(function(x){x{"publicKeyBase58"}})
      their_vk = publicKeys.head()
      service = connection{["DIDDoc","service"]}
        .filter(function(x){
          x{"type"}=="IndyAgent"
          && x{"id"}.match(their_did+";indy")
        }).head()
      se = service{"serviceEndpoint"}
      their_rks = service{"routingKeys"}.defaultsTo([])
      chann = event:attr("channel")
      my_did = chann{"id"}
      my_vk = chann{["sovrin","indyPublic"]}
      ri = event:attr("routing").klog("routing information")
      rks = ri => ri{"their_routing"} | null
      endpoint = ri => ri{"endpoint"} | a_msg:localServiceEndpoint(my_did)
      rm = a_msg:connResMap(req_id, my_did, my_vk, endpoint,rks)
      c = {
        "created": time:now(),
        "label": msg{"label"},
        "my_did": my_did,
        "their_did": their_did,
        "their_vk": their_vk,
        "their_endpoint": se,
        "their_routing": their_rks,
      }
      pm = a_msg:packMsg(c,rm,meta:eci)
    }
    fired {
      raise agent event "new_connection" attributes c;
      raise sovrin event "new_ssi_agent_wire_message" attributes {
        "serviceEndpoint": se, "packedMessage": pm
      }
    }
  }
//
// connections/response
//
  rule handle_connections_response {
    select when sovrin connections_response
    pre {
      msg = event:attr("message")
      verified = a_msg:verify_signatures(msg)
      connection = verified{"connection"}
      service = connection && connection{["DIDDoc","service"]}
        .filter(function(x){x{"type"}=="IndyAgent"})
        .head()
      their_vk = service{"recipientKeys"}.head()
      their_rks = service{"routingKeys"}.defaultsTo([])
      cid = msg{["~thread","thid"]}
      index = ent:pending_conn.defaultsTo([])
        .reduce(function(a,p,i){
          a<0 && p{"@id"}==cid => i | a
        },-1)
      c = index < 0 => null | ent:pending_conn[index]
        .delete("@id")
        .put({
          "created": time:now(),
          "their_did": connection{"DID"},
          "their_vk": their_vk,
          "their_endpoint": service{"serviceEndpoint"},
          "their_routing": their_rks,
        })
    }
    if typeof(index) == "Number" && index >= 0 then noop()
    fired {
      raise agent event "new_connection" attributes c;
      ent:pending_conn := ent:pending_conn.splice(index,1)
    }
  }
//
// record a new connection
//
  rule record_new_connection {
    select when agent new_connection
    pre {
      their_vk = event:attr("their_vk")
    }
    fired {
      ent:connections{their_vk} := event:attrs;
      raise agent event "connections_changed"
        attributes { "connections": ent:connections }
    }
  }
//
// trust_ping/ping
//
  rule handle_trust_ping_request {
    select when sovrin trust_ping_ping
    pre {
      msg = event:attr("message")
      rm =a_msg:trustPingResMap(msg{"@id"})
      their_key = event:attr("sender_key")
      conn = ent:connections{their_key}
      pm = a_msg:packMsg(conn,rm)
      se = conn{"their_endpoint"}
      may_respond = msg{"response_requested"} == false => false | true
    }
    if se && may_respond then noop()
    fired {
      raise sovrin event "new_ssi_agent_wire_message" attributes {
        "serviceEndpoint": se, "packedMessage": pm
      }
    }
  }
//
// trust_ping/ping_response
//
  rule handle_trust_ping_ping_response {
    select when sovrin trust_ping_ping_response
  }
//
// initiate trust ping
//
  rule initiate_trust_ping {
    select when sovrin trust_ping_requested
    pre {
      their_vk = event:attr("their_vk")
      conn = ent:connections{their_vk}
      rm = a_msg:trustPingMap()
      pm = a_msg:packMsg(conn,rm)
      se = conn{"their_endpoint"}
    }
    if se then noop()
    fired {
      raise sovrin event "new_ssi_agent_wire_message" attributes {
        "serviceEndpoint": se, "packedMessage": pm
      }
    }
  }
//
// basicmessage/message
//
  rule handle_basicmessage_message {
    select when sovrin basicmessage_message
    pre {
      their_key = event:attr("sender_key")
      conn = ent:connections{their_key}
      msg = event:attr("message")
      wmsg = conn.put(
        "messages",
        conn{"messages"}.defaultsTo([])
          .append(msg.put("from","incoming"))
      )
    }
    fired {
      ent:connections{their_key} := wmsg
    }
  }
//
// initiate basicmessage
//
  rule initiate_basicmessage {
    select when sovrin send_basicmessage
    pre {
      their_key = event:attr("their_vk")
      conn = ent:connections{their_key}
      content = event:attr("content").decode()
      bm = a_msg:basicMsgMap(content)
      pm = a_msg:packMsg(conn,bm)
      se = conn{"their_endpoint"}
      wmsg = conn.put(
        "messages",
        conn{"messages"}.defaultsTo([])
          .append(bm.put("from","outgoing")
                    .put("color",vp:colorRGB().join(","))
                 )
      )
    }
    if se then noop()
    fired {
      raise sovrin event "new_ssi_agent_wire_message" attributes {
        "serviceEndpoint": se, "packedMessage": pm
      };
      ent:connections{their_key} := wmsg
    }
  }
//
// convenience rule to clean up known expired connection
//
  rule delete_connection {
    select when sovrin connection_expired
    pre {
      their_vk = event:attr("their_vk")
      pairwise = ent:connections{their_vk}
      the_did = pairwise{"my_did"}
      override = event:attr("final_cleanup")
    }
    if the_did == meta:eci || override then
      send_directive("delete",{"connection":pairwise})
    fired {
      clear ent:connections{their_vk};
      raise edge event "router_connection_deletion_requested"
        attributes {"label":pairwise{"label"}};
      raise wrangler event "channel_deletion_requested"
        attributes {"eci": the_did} if wrangler:channel(the_did);
      raise agent event "connections_changed"
        attributes { "connections": ent:connections }
    }
  }

  rule update_connection_endpoint {
    select when sovrin update_endpoint
    pre {
      my_did = event:attr("my_did")
      new_endpoint_host = event:attr("their_host")
      new_endpoint = getEndpoint(my_did, new_endpoint_host)
    }
    fired {
      ent:connections := ent:connections.map(function(v, k) {
        (v{"my_did"} == my_did) => v.set(["their_endpoint"], new_endpoint)| v
      })
    }
  }
//
// clean up internal data structures as needed
//
  rule clean_up_pending_connections {
    select when agent pending_connections_cleanup_requested
    foreach ent:pending_conn.defaultsTo([]) setting(conn)
    pre {
      eci = conn{"my_did"}
      label = conn{"label"}
    }
    if eci && label then noop()
    fired {
      raise edge event "router_connection_deletion_requested"
        attributes {"label":label};
      raise wrangler event "channel_deletion_requested"
        attributes {"eci":eci} if wrangler:channel(eci)
    }
    finally {
      raise agent event "pending_connections_cleanup_completed" attributes {} on final
    }
  }
  rule finalize_clean_up_pending_connections {
    select when agent pending_connections_cleanup_completed
    fired {
      clear ent:pending_conn;
      raise agent event "pending_connections_cleared" attributes {}
    }
  }
  rule clean_up_prior_to_pico_deletion_part0 {
    select when wrangler rulesets_need_to_cleanup
      where wrangler:channel("agent")
    fired {
      raise wrangler event "channel_deletion_requested"
        attributes {"name":"agent"}
    }
  }
  rule clean_up_prior_to_pico_deletion_part1a {
    select when wrangler rulesets_need_to_cleanup
    fired {
      raise agent event "pending_connections_cleanup_requested" attributes {}
    }
  }
  rule clean_up_prior_to_pico_deletion_part1b {
    select when wrangler rulesets_need_to_cleanup
      where ent:pending_conn.isnull()
    fired {
      raise agent event "pending_connections_cleared" attributes {}
    }
  }
  rule clean_up_prior_to_pico_deletion_part2a {
    select when wrangler rulesets_need_to_cleanup
    foreach ent:connections.keys() setting(vk)
    fired {
      raise sovrin event "connection_expired"
        attributes {"their_vk":vk,"final_cleanup":true}
    }
    finally {
      raise agent event "connections_cleared" attributes {} on final
    }
  }
  rule clean_up_prior_to_pico_deletion_part2b {
    select when wrangler rulesets_need_to_cleanup
      where ent:connections.keys().length() == 0
    fired {
      raise agent event "connections_cleared" attributes {}
    }
  }
  rule clean_up_prior_to_pico_deletion_part3 {
    select when wrangler rulesets_need_to_cleanup
      before (agent pending_connections_cleared
        and agent connections_cleared)
    fired {
      raise wrangler event "cleanup_finished"
        attributes {"domain": meta:rid}
    }
  }
  rule prepare_to_clean_up_connections {
    select when agent connections_cleanup_requested
    pre {
      bad_connections =
        ent:connections
          .filter(function(v){v{"their_vk"}.isnull()})
      clean_connections =
        ent:connections
          .filter(function(v){v{"their_vk"}})
    }
    send_directive("clean_connections",{
      "bad_connections":bad_connections,
      "clean_connections":clean_connections
    })
    fired {
      raise agent event "ready_to_clean_up_connections" attributes {
        "bad_connections":bad_connections,
        "clean_connections":clean_connections
      }
    }
  }
  rule clean_up_connections {
    select when agent ready_to_clean_up_connections
    foreach event:attr("bad_connections") setting(conn)
    pre {
      label = conn{"label"}
      eci = conn{"my_did"}
    }
    fired {
      raise edge event "router_connection_deletion_requested"
        attributes {"label":label};
      raise wrangler event "channel_deletion_requested"
        attributes {"eci":eci} if wrangler:channel(eci)
    }
    finally {
      ent:connections := event:attr("clean_connections") on final
    }
  }
}
