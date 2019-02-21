ruleset org.sovrin.agent {
  meta {
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
    invitationMap = function(sEp,rKs){
      {
        "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation",
        "@id": random:uuid(),
        "label": random:word(),
        "recipientKeys": [rKs],
        "serviceEndpoint": sEp//,
        //"routingKeys": [rKs]
      }
    }
    invitation = function(){
      uKR = agent_Rx();
      eci = uKR{"id"};
      eid = "null";
      d ="sovrin";
      t = "new_message";
      sEp = <<#{meta:host}/sky/event/#{eci}/#{eid}/#{d}/#{t}>>;
      im = invitationMap(sEp,uKR{["sovrin","indyPublic"]}).encode();
      ep = <<#{meta:host}/sky/cloud/#{eci}/org.sovrin.agent.ui/html.html>>;
      ep + "?c_i=" + math:base64encode(im)
    }
  }
  rule route_new_message {
    select when sovrin new_message protected re#(.*)# setting(protected)
    pre {
      tolog = klog(event:attrs.keys(),"event:attrs.keys()")
      outer = math:base64decode(protected).klog("outer")
      msg = indy:unpack(event:attrs,meta:eci){"message"}.decode()
      msg_type = msg{"@type"}.klog("msg_type")
    }
    if msg_type.match(re#;spec/connections/1.0/request$#) then
    send_directive("connection request")
    fired {
      raise sovrin event "connection_request" attributes msg
    }
  }
  rule handle_connection_request {
    select when sovrin connection_request label re#(.+)# setting(label)
    pre {
      connection = event:attr("connection").klog("connection")
      publicKeys = connection{["DIDDoc","publicKey"]}
        .map(function(x){x{"publicKeyBase58"}}).klog("publicKeys")
      se = connection{["DIDDoc","service"]}.head(){"serviceEndpoint"}.klog("se")
      rm = {
        "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/response"
        }.klog("response message")
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
