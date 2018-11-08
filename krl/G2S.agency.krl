ruleset G2S.agency {
  meta {
    shares __testing
    use module G2S.indy_sdk.pool   alias pool_module

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
    config={"rids": ["G2S.indy_sdk.ledger"
                    ,"G2S.indy_sdk.pool"
                    ,"G2S.indy_sdk.wallet"
                    ,"G2S.agent"]};
    
  }
  rule constructor {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    
  }
  rule systemOnLine { // connect to pool when the engine starts
    select when system online
    pool_module:open("rLJJ41TslS")
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
    select when agency CREATE
    always {
      raise wrangler event "child_creation" 
        attributes { "name": event:attr("name"), "color": "#7FFFD4", "rids": config{"rids"},"event_type": "agent_create" }
    }
  }
  rule delete_agent {
    select when agency DELETE
    always {
      raise wrangler event "child_deletion" 
        attributes { "name": event:attr("name"), "rids": config{"rids"},"event_type": "agent_delete" }
    }
  }

  rule generateQRcode {
    select when agency generate_qr_code_offer
  }
}
