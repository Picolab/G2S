ruleset G2S.agency {
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
    config={"pico_name" : "agentTest", "rids": ["io.picolabs.subscription"]};
    
  }
  rule constructor {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    
  }
  rule handleMsg {
    select when agency msg_handler
  }
  rule CONNECT {
    select when agency CONNECT
  }
  rule SIGNUP {
    select when agency SIGNUP
  }
  rule CREATE_AGENT {
    select when agency CREATE_AGENT
    always {
      raise wrangler event "child_creation" 
        attributes { "name": config{"pico_name"}, "color": "#7FFFD4", "rids": config{"rids"},"event_type": "agent_creation" }
    }
  }

  rule generateQRcode {
    select when agency generate_qr_code_offer
  }
}
