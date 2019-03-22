ruleset org.sovrin.agency_agent {
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
  rule initialize_agency_agent {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      rs_attrs = event:attr("rs_attrs")
      subs_eci = rs_attrs{"subs_eci"}
      name = rs_attrs{"name"}
    }
    fired {
      raise wrangler event "subscription" attributes {
        "wellKnown_Tx": subs_eci,
        "Rx_role": "agent",
        "Tx_role": "agency",
        "name": name,
        "channel_type": "subscription"
      }
    }
  }
}
