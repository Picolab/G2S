ruleset org.sovrin.agency {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module org.sovrin.agency.ui alias ui
    shares __testing, html
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "agency", "type": "new_agent", "attrs": [ "name", "color", "label" ] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    html = function(){
      ui:html()
    }
    agents_rids = [
      "io.picolabs.collection",
      "org.sovrin.agents"
    ]
    agent_rids = [
      "org.sovrin.agent_message",
      "org.sovrin.agent.ui",
      "org.sovrin.agent",
      "org.sovrin.agency_agent"
    ]
  }
  rule initialize_agency {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    if ent:agents_eci.isnull() then
      wrangler:createChannel(meta:picoId,"agency","sovrin") setting(channel)
    fired {
      raise wrangler event "new_child_request" attributes {
        "name": "Agents", "rids": agents_rids,
        "agency_eci": channel{"id"}, "color": "#f6a12b"
      }
    }
  }
  rule record_agents_eci {
    select when agents ready agents_eci re#(.+)# setting(agents_eci)
    pre {
      wellKnown_Rx = wrangler:skyQuery(agents_eci,
        "io.picolabs.subscription",
        "wellKnown_Rx")
      subs_eci = wellKnown_Rx{"error"} => null | wellKnown_Rx{"id"}
    }
    fired {
      ent:agents_eci := agents_eci;
      ent:subs_eci := subs_eci
    }
  }
  rule create_new_agent_pico {
    select when agency new_agent
    pre {
      child_specs = event:attrs
        .delete("_headers")
        .put({ "subs_eci": ent:subs_eci })
    }
    every {
      event:send({"eci":wrangler:parent_eci(),
        "domain": "wrangler", "type": "new_child_request",
        "attrs": child_specs.put({"rids":agent_rids})
      });
    }
  }
}
