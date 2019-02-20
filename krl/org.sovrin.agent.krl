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
        "serviceEndpoint": sEp,
        "routingKeys": [rKs]
      }
    }
    invitation = function(){
      uKR = agent_Rx();
      eci = uKR{"id"};
      eid = "null";
      d ="sovrin";
      t = "pending_invitation";
      ep = <<#{meta:host}/sky/event/#{eci}/#{eid}/#{d}/#{t}>>;
      im = invitationMap(ep,uKR{["sovrin","verifyKey"]}).encode();
      ep + "?c_i=" + math:base64encode(im)
    }
  }
  rule accept_connection_request {
    select when sovrin pending_invitation protected re#(.*)# setting(protected)
    pre {
      tolog = klog(event:attrs.keys(),"event:attrs.keys()")
      message = math:base64decode(protected).klog("message")
    }
    send_directive("process")
  }
}
