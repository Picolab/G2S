ruleset org.sovrin.agent {
  meta {
    use module org.sovrin.agent_message alias a_msg
    use module io.picolabs.wrangler alias wrangler
    shares __testing, agent_Rx, invitationMap, invitation
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "agent_Rx" }
      , { "name": "invitationMap", "args": [ "sEp", "rKs" ] }
      , { "name": "invitation" }
      ] , "events":
      [ { "domain": "sovrin", "type": "pending_invitation", "attrs": [ "connection" ] }
      , { "domain": "sovrin", "type": "connection_request_retry_needed", "attrs": [] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    agent_Rx = function(){
      wrangler:channel("agent")
    }
    sEp = function(eci,eid,e_d,e_t){
      d = e_d || "sovrin";
      t = e_t || "new_message";
      <<#{meta:host}/sky/event/#{eci}/#{eid}/#{d}/#{t}>>
    }
    invitation = function(){
      uKR = agent_Rx();
      eci = uKR{"id"};
      eid = "null";
      d ="sovrin";
      t = "new_message";
      sEp = <<#{meta:host}/sky/event/#{eci}/#{eid}/#{d}/#{t}>>;
      im = a_msg:invitationMap(
        ent:label,
        null, // @id
        uKR{["sovrin","indyPublic"]},
        sEp
      );
      ep = <<#{meta:host}/sky/cloud/#{eci}/org.sovrin.agent.ui/html.html>>;
      ep + "?c_i=" + math:base64encode(im.encode())
    }
  }
  rule route_new_message {
    select when sovrin new_message protected re#(.*)# setting(protected)
    pre {
      tolog = klog(event:attrs.keys(),"event:attrs.keys()")
      outer = math:base64decode(protected).klog("outer")
      msg = indy:unpack(event:attrs,meta:eci){"message"}.decode()
      msg_type = msg{"@type"}.klog("msg_type")
      event_type = a_msg:specToEventType(msg_type)
    }
    if event_type then
      send_directive("message routed",{"event_type":event_type})
    fired {
      raise sovrin event event_type attributes msg
    }
  }
  rule handle_connections_request {
    select when sovrin connections_request label re#(.+)# setting(label)
    pre {
      connection = event:attr("connection").klog("connection")
      publicKeys = connection{["DIDDoc","publicKey"]}
        .map(function(x){x{"publicKeyBase58"}}).klog("publicKeys")
      se = connection{["DIDDoc","service"]}.head(){"serviceEndpoint"}.klog("se")
      req_id = connection{"id"}
      chann = agent_Rx()
      my_did = chann{"id"}
      my_vk = chan{["sovrin","indyPublic"]}
      endpoint = sEp(my_did)
      rm = a_msg:connResMap(req_id, my_did, my_vk, endpoint)
        .klog("response message")
      pm = indy:pack(rm,publicKeys,meta:eci).klog("packed message")
    }
    http:post(se,body=pm) setting(http_response)
    fired {
      ent:agent_request := event:attrs;
      ent:se := se;
      ent:pm := pm;
      ent:http_response := http_response
    }
  }
  rule retry_connection_request {
    select when sovrin connection_request_retry_needed
    http:post(ent:se,body=ent:pm) setting(http_response)
    fired {
      klog(http_response)
    }
  }
}
