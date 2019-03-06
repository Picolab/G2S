ruleset org.sovrin.wire_message {
  meta {
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
      headers={"content-type":"application/ssi-agent-wire"}
    ) setting(http_response)
    fired {
      ent:last_http_response := http_response;
      klog(http_response,"http_response")
    }
  }
}
