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
    // message types

    t_basic_msg = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/basicmessage/1.0/message"

    t_conn_invit = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation"
    t_conn_req = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/request"
    t_conn_res = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/response"

    t_ping_req = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/trust_ping/1.0/ping"
    t_ping_res = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/trust_ping/1.0/ping_response"

    invitationMap = function(id,label,key,endpoint){
      {
        "@type": t_conn_invit,
        "@id": id || random:uuid(),
        "label": label || random:word(),
        "recipientKeys": [key],
        "serviceEndpoint": endpoint
      }
    }
  }
}
