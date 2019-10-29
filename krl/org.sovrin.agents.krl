ruleset org.sovrin.agents {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.collection alias agents
    shares __testing, agents, agentByName
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "agents" }
      , { "name": "agentByName", "args": [ "name" ] }
      ] , "events":
      [ { "domain": "agent", "type": "new_login_did", "attrs": [ "name", "did" ] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    agents = function(){
      agents:members()
    }
    agentByName = function(name){
      id = ent:agents{name};
      id => agents().filter(function(x){x{"Id"}==id})
                    .head()
                    .put("name",name)
                    .put("did",ent:logins{name})
          | null
    }
  }
  rule initialize_agency {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      agency_eci = event:attr("agency_eci")
        || event:attr("rs_attrs"){"agency_eci"}
    }
    if ent:agency_eci.isnull() && ent:agents.isnull() then
    every {
      wrangler:createChannel(meta:picoId,"agents","sovrin") setting(channel);
      event:send({"eci":agency_eci, "domain":"agents", "type":"ready",
        "attrs": {"agents_eci":channel{"id"}}
      })
    }
    fired {
      ent:agency_eci := agency_eci;
      ent:agents := {};
      raise collection event "new_role_names" attributes {
        "Tx_role": "agent", "Rx_role": "agency"
      }
    }
  }
  rule map_id_to_name {
    select when collection new_member
    pre {
      name = event:attr("name")
      id = event:attr("Id")
    }
    fired {
      ent:agents{name} := id
    }
  }
  rule unmap_name {
    select when collection member_removed Id re#(.+)# setting(id)
    pre {
      remaining_agents = ent:agents
        .filter(function(v,k){v!=id})
    }
    fired {
      ent:agents := remaining_agents
    }
  }
  rule store_login_did {
    select when agent new_login_did
    fired {
      ent:logins{event:attr("name")} := event:attr("did")
    }
  }
}
