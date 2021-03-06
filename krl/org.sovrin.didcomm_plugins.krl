ruleset org.sovrin.didcomm_plugins {
  meta {
    shares __testing, ruleset_available
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "ruleset_available", "args": [ "piuri" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    mturi = re#(.*?[a-z0-9._-]+\d[^/]*)/([a-z0-9._-]+)$#
    ruleset_available = function(piuri){
      engine:listAllEnabledRIDs()
        .difference(engine:listInstalledRIDs())
        .filter(function(rid){
          engine:describeRuleset(rid){["meta","description"]}
            .match(piuri)
        })
    }
  }
//
// bookkeeping
//
  rule keep_plugin_list_up_to_date {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    fired {
      raise agent event "request_for_plug_ins"
    }
  }
  rule update_plugin_list {
    select when agent plugin_reported
    pre {
      piuri = event:attr("piuri")
      rid = event:attr("rid")
    }
    if piuri && rid then noop()
    fired {
      ent:plugins{piuri} := event:attrs
    }
  }
//
// eavesdrop incoming agent basicmessages for one of interest
//
  rule eavesdrop_basicmessage {
    select when sovrin basicmessage_message
      where event:attr("message"){["content","@type"]}.match(mturi)
    pre {
      parts = event:attr("message"){["content","@type"]}.extract(mturi)
      piuri = parts.head()
      content = event:attr("message"){"content"}
      event_type = parts[1]
      sender_key = event:attr("sender_key")
      pass_attrs = {
        "piuri":piuri,
        "event_type":event_type,
        "content":content,
        "sender_key":sender_key
      }
      plugin = ent:plugins{piuri}
      plugin_rid = plugin{"rid"}
    }
    if plugin_rid && engine:listInstalledRIDs() >< plugin_rid then noop()
    fired {
      raise plugin event "protocol_message_received" attributes pass_attrs
    } else {
      raise plugin event "need_protocol_plugin" attributes pass_attrs
    }
  }
  rule install_plugin_ruleset_for_piuri {
    select when plugin need_protocol_plugin
    pre {
      rid = ruleset_available(event:attr("piuri")).head()
    }
    if rid then noop()
    fired {
      raise wrangler event "install_rulesets_requested" attributes {
        "rids": rid,
        "pass_attrs": event:attrs
      }
    }
  }
  rule pass_attributes_to_new_protocol_plugin {
    select when wrangler ruleset_added
    pre {
      pass_attrs = event:attr("pass_attrs")
    }
    if pass_attrs then noop()
    fired {
      raise plugin event "protocol_message_received" attributes pass_attrs
    }
  }
}
