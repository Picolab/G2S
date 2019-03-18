ruleset org.sovrin.agent {
  meta {
    use module org.sovrin.agent_message alias a_msg
    use module io.picolabs.wrangler alias wrangler
    shares __testing, ui
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      ] , "events":
      [ 
      ]
    }
    connection = function(key){
      ent:connections{key}
    }
    ui = function(){
      connections = ent:connections
        .values()
        .sort(function(a,b){
          a{"created"} cmp b{"created"}
        });
      {
        "name": wrangler:name(),
        "connections": connections.length() => connections | null,
        "invitation": invitation()
      }
    }
    sEp = function(eci,eid,e_d,e_t){
      d = e_d || "sovrin";
      t = e_t || "new_message";
      <<#{meta:host}/sky/event/#{eci}/#{eid}/#{d}/#{t}>>
    }
    invitation = function(){
      uKR = ent:invitation_channel;
      eci = uKR{"id"};
      im = a_msg:connInviteMap(
        ent:label,
        null, // @id
        uKR{["sovrin","indyPublic"]},
        sEp(eci)
      );
      ep = <<#{meta:host}/sky/cloud/#{eci}/org.sovrin.agent.ui/html.html>>;
      ep + "?c_i=" + math:base64encode(im.encode())
    }
  }
//
// on ruleset_added
//
rule on_installation {
  select when wrangler ruleset_added where event:attr("rids") >< meta:rid
  wrangler:createChannel(meta:picoId,"agent","sovrin") setting(channel)
  fired {
    ent:invitation_channel := channel
  }
}
//
// accept invitation
//
  rule accept_invitation {
    select when sovrin new_invitation url re#(http.+)# setting(url)
    pre {
      qs = url.split("?").tail().join("?")
      args = qs.split("&")
        .map(function(x){x.split("=")})
        .collect(function(x){x[0]})
        .map(function(x){x[0][1]})
      c_i = args{"c_i"}
      im = math:base64decode(c_i).decode()
      their_label = im{"label"}
    }
    if im && their_label then
      wrangler:createChannel(meta:picoId,their_label,"connection")
        setting(channel)
    fired {
      raise sovrin event "invitation_accepted"
        attributes { "invitation": im, "channel": channel }
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
      rm = a_msg:connReqMap(
        label,
        my_did,
        my_vk,
        sEp(my_did)
      )
      reqURL = im{"serviceEndpoint"}
      packedBody = indy:pack(
        rm.encode(),
        im{"recipientKeys"},
        my_did
      )
      pc = {
        "label": im{"label"},
        "my_did": my_did,
        "@id": rm{"@id"}
      }
    }
    fired {
      ent:pending_conn := ent:pending_conn.defaultsTo([]).append(pc);
      ent:connReq := ent:connReq.defaultsTo(0) + 1;
      raise wrangler event "new_child_request" attributes {
        "name": "connReq" + ent:connReq, "rids": "org.sovrin.wire_message",
        "serviceEndpoint": reqURL, "packedMessage": packedBody
      }
    }
  }
//
// receive messages
//
  rule route_new_message {
    select when sovrin new_message protected re#(.*)# setting(protected)
    pre {
      outer = math:base64decode(protected).decode()
      kids = outer{"recipients"}
        .map(function(x){x{["header","kid"]}})
      my_vk = wrangler:channel(meta:eci){["sovrin","indyPublic"]}
      sanity = (kids >< my_vk)
        .klog("sanity")
      all = indy:unpack(event:attrs,meta:eci)
      their_key = all{"sender_key"}
      my_key = all{"recipient_key"}
      msg = all{"message"}.decode()
      msg_type = msg{"@type"}
      event_type = a_msg:specToEventType(msg_type)
    }
    if event_type then
      send_directive("message routed",{"event_type":event_type})
    fired {
      raise sovrin event event_type attributes all.put("message",msg)
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
    }
    if their_label then
      wrangler:createChannel(meta:picoId,their_label,"connection")
        setting(channel)
    fired {
      raise sovrin event "connections_request_accepted"
        attributes { "message": msg, "channel": channel }
    }
  }
  rule initiate_connections_response {
    select when sovrin connections_request_accepted
    pre {
      msg = event:attr("message")
      req_id = msg{"@id"}
      connection = msg{"connection"}
      publicKeys = connection{["DIDDoc","publicKey"]}
        .map(function(x){x{"publicKeyBase58"}})
      their_vk = publicKeys.head()
      se = connection{["DIDDoc","service"]}.head(){"serviceEndpoint"}
      chann = event:attr("channel")
      my_did = chann{"id"}
      my_vk = chann{["sovrin","indyPublic"]}
      endpoint = sEp(my_did)
      rm = a_msg:connResMap(req_id, my_did, my_vk, endpoint)
      pm = indy:pack(rm.encode(),publicKeys,meta:eci)
      c = {
        "created": time:now(),
        "label": msg{"label"},
        "my_did": my_did,
        "their_did": connection{"DID"},
        "their_vk": their_vk,
        "their_endpoint": se
      }
    }
    fired {
      ent:connections{their_vk} := c;
      ent:connRes := ent:connRes.defaultsTo(0) + 1;
      raise wrangler event "new_child_request" attributes {
        "name": "connRes" + ent:connRes, "rids": "org.sovrin.wire_message",
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
      cid = verified{["~thread","thid"]}
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
          "their_endpoint": service{"serviceEndpoint"}
        })
    }
    if typeof(index) == "Number" && index >= 0 then noop()
    fired {
      ent:connections{their_vk} := c;
      ent:pending_conn := ent:pending_conn.splice(index,1)
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
      conn = connection(their_key)
      pm = indy:pack(rm.encode(),[their_key],conn{"my_did"})
      se = conn{"their_endpoint"}
      may_respond = msg{"response_requested"} == false => false | true
    }
    if se && may_respond then
      http:post(se,body=pm) setting(http_response)
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
      conn = connection(their_vk)
      rm = a_msg:trustPingMap()
      pm = indy:pack(
        rm.encode(),
        [their_vk],
        conn{"my_did"}
      )
      se = conn{"their_endpoint"}
    }
    if se then noop()
    fired {
      ent:pingReq := ent:pingReq.defaultsTo(0) + 1;
      raise wrangler event "new_child_request" attributes {
        "name": "pingReq" + ent:pingReq, "rids": "org.sovrin.wire_message",
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
      conn = connection(their_key)
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
      conn = connection(their_key)
      content = event:attr("content")
      bm = a_msg:basicMsgMap(content)
      pm = indy:pack(bm.encode(),[their_key],conn{"my_did"})
      se = conn{"their_endpoint"}
      wmsg = conn.put(
        "messages",
        conn{"messages"}.defaultsTo([])
          .append(bm.put("from","outgoing"))
      )
    }
    if se then
      http:post(se,body=pm) setting(http_response)
    fired {
      ent:connections{their_key} := wmsg
    }
  }
//
// convenience rule to clean up known expired connection
//
  rule delete_connection {
    select when sovrin connection_expired
    pre {
      my_did = meta:eci
      their_vk = event:attr("their_vk")
      pairwise = ent:connections{their_vk}
    }
    if pairwise{"my_did"} == meta:eci then
      send_directive("delete",{"connection":pairwise})
    fired {
      ent:connections := ent:connections.delete(their_vk);
      raise wrangler event "channel_deletion_requested" attributes {
        "eci": my_did
      }
    }
  }
}
