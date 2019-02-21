ruleset org.sovrin.agent_message {
  meta {
    provides invitationMap
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    invitationMap = function(id,label,key,endpoint){
      {
        "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation",
        "@id": id || random:uuid(),
        "label": label || random:word(),
        "recipientKeys": [key],
        "serviceEndpoint": endpoint
      }
    }
  }
}
