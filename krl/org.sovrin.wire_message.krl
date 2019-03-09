ruleset org.sovrin.wire_message {
  meta {
    use module io.picolabs.wrangler alias wrangler
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
// on ruleset_added
//
rule on_installation {
  select when wrangler ruleset_added where event:attr("rids") >< meta:rid
  pre {
    wire_message = event:attr("rs_attrs")
    se = wire_message{"serviceEndpoint"}
    pm = wire_message{"packedMessage"}
  }
  if wire_message then noop()
  fired {
    raise sovrin event "new_ssi_agent_wire_message" attributes {
      "serviceEndpoint": se, "packedMessage": pm
     }
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
      klog(http_response,"http_response");
      raise sovrin event "mission_accomplished"
        if http_response{"status_code"}.match(re#^2\d\d$#)
    }
  }
//
// done so cease to exist
//
  rule done_so_cease_to_exist {
    select when sovrin mission_accomplished
    pre {
      eci = wrangler:parent_eci()
    }
    if eci then
    event:send({"eci": eci, "domain": "wrangler", "type": "child_deletion",
      "attrs": {
        "id": meta:picoId.klog("id"),
        "name": wrangler:name().klog("name")}
    })
  }
}
