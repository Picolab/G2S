ruleset org.sovrin.agency_agent {
  meta {
    use module io.picolabs.subscription alias subs
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
    login_channel_spec = {"name":"login", "type":"secret"}
  }
  rule initialize_agency_agent {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      rs_attrs = event:attr("rs_attrs")
      subs_eci = event:attr("subs_eci") || rs_attrs{"subs_eci"}
      name = event:attr("name") || rs_attrs{"name"}
    }
    fired {
      raise wrangler event "subscription" attributes {
        "wellKnown_Tx": subs_eci,
        "Rx_role": "agent",
        "Tx_role": "agency",
        "name": name,
        "channel_type": "subscription"
      };
      ent:name := name;
      raise wrangler event "channel_creation_requested"
        attributes login_channel_spec;
    }
  }
  rule save_login_did {
    select when wrangler channel_created
      name re#^login$# type re#^secret$#
    pre {
      channel = event:attr("channel").klog("channel")
    }
    fired {
      ent:saved_eci := channel{"id"}
    }
  }
  rule communicate_login_did {
    select when wrangler outbound_pending_subscription_approved
    event:send({"eci":event:attr("Tx"),
      "domain": "agent", "type": "new_login_did",
      "attrs": {"name": ent:name, "did": ent:saved_eci}
    })
  }
}
