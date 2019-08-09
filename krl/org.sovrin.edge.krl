ruleset org.sovrin.edge {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module org.sovrin.agent_message alias a_msg
    shares __testing, get_vk, get_did, invitation_via, ui
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "get_vk", "args": [ "label" ] }
      , { "name": "get_did", "args": [ "vk" ] }
      , { "name": "invitation_via", "args": [ "label" ] }
      , { "name": "ui" }
      ] , "events":
      [ { "domain": "edge", "type": "new_router", "attrs": [ "host", "eci", "label" ] }
      , { "domain": "edge", "type": "poll_needed", "attrs": [ "label" ] }
      , { "domain": "edge", "type": "poll_all_needed" }
      , { "domain": "edge", "type": "router_connection_deletion_requested", "attrs": [ "label" ] }
      ]
    }
    get_vk = function(label){
      extendedLabel = label + " to " + wrangler:name();
      ent:routerConnections{[extendedLabel,"their_vk"]}
    }
    get_did = function(vk){
      wrangler:channel()
        .filter(function(x){x{["sovrin","indyPublic"]} == vk})
        .head(){"id"}
    }
    invitation_via = function(label){
      extendedLabel = label + " to " + wrangler:name();
      eci = ent:routerConnections{[extendedLabel,"my_did"]};
      routing = ent:routerConnections{[extendedLabel,"their_routing"]};
      endpoint = <<#{ent:routerHost}/sky/event/#{eci}/null/sovrin/new_message>>;
      i = a_msg:connInviteMap(null,wrangler:name(),get_vk(label),endpoint,routing);
      <<#{ent:routerHost}/sky/cloud/#{eci}/org.sovrin.agent/html.html>>
        + "?c_i=" + math:base64encode(i.encode())
    }
    ui = function() {
      ent:routerConnections.keys().length() == 0 => null |
      {
        "routerName": ent:routerName,
        "routerHost": ent:routerHost,
        "routerRequestECI": ent:routerRequestECI,
        "routerConnections": ent:routerConnections,
        "invitationViaRouter": invitation_via(ent:routerName),
      }
    }
    cleanup_router = defaction(eci,vk,oldTags){
      needed = oldTags.length() > 0 => "Yes" | "No"
      url = <<#{ent:routerHost}/sky/event/#{eci}/cleanup/router/messages_not_needed>>
      choose needed {
        Yes => http:post(url,json={"vk":vk,"msgTags":oldTags},
          autosend={"eci":meta:eci,"domain":"edge","type":"http_post_response"});
        No  => noop();
      }
    }
  }
  rule initialize_a_router {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    fired {
      ent:routerConnections := {};
      ent:msgTags := {};
      raise edge event "new_router" attributes event:attrs
    }
  }
  rule edge_new_router {
    select when edge new_router
      host re#(https?://.+)#
      eci re#(.+)#
      label re#(.+)#
      setting(host,eci,label)
    pre {
      extendedLabel = label + " to " + wrangler:name()
    }
    wrangler:createChannel(meta:picoId,extendedLabel,"router")
      setting(channel)
    fired {
      raise edge event "need_router_connection" attributes {
        "channel": channel,
        "label": label,
      };
      ent:routerHost := host;
      ent:routerRequestECI := eci;
      ent:routerName := label // we only get one router for now
    }
  }
//
// router connection with a pre-existing channel
//
  rule make_router_connection {
    select when edge need_router_connection
    pre {
      channel = event:attr("channel")
      routerRequestURL = <<#{ent:routerHost}/sky/event/#{ent:routerRequestECI}/null/router/request>>
      extendedLabel = event:attr("label") + " to " + wrangler:name()
    }
    http:post(routerRequestURL,qs={
      "final_key":channel{["sovrin","indyPublic"]},
      "label":extendedLabel,
    }) setting(response)
    fired {
      raise edge event "new_router_connection"
        attributes event:attrs.put(response.decode())
    }
  }
  rule record_new_router_connection {
    select when edge new_router_connection
    pre {
      ok = event:attr("status_code") == 200
      directives = ok => event:attr("content").decode(){"directives"} | null
      connection = ok => directives
        .filter(function(x){x{"name"}=="request accepted"})
        .head(){["options","connection"]} | null
      endpoint = <<#{ent:routerHost}/sky/event/#{connection{"my_did"}}/null/sovrin/new_message>>
    }
    if ok && connection{"label"} then noop()
    fired {
      ent:routerConnections{[connection{"label"}]} := connection;
      raise edge event "new_router_connection_recorded"
        attributes event:attrs.put("routing",
          connection.put("endpoint",endpoint))
    } else {
      ent:failedResponse := event:attrs
    }
  }
  rule poll_for_messages {
    select when edge poll_needed label re#(.+)# setting(label)
    pre {
      extendedLabel = label + " to " + wrangler:name()
      router_eci = ent:routerConnections{[extendedLabel,"my_did"]}
      url = <<#{ent:routerHost}/sky/cloud/#{router_eci}/org.sovrin.router/stored_msgs>>
      vk = get_vk(label)
      exceptions = ent:msgTags{vk}.defaultsTo([])
      eci = vk => get_did(vk) | null
      res = eci => http:get(url,qs={"vk":vk,"exceptions":exceptions}) | {}
      messages = res{"status_code"} == 200 => res{"content"}.decode() | null
    }
    if vk && eci && messages then cleanup_router(router_eci,vk,exceptions)
    fired {
      clear ent:msgTags{vk};
      raise edge event "new_messages" attributes {
        "messages":messages, "eci": eci, "vk": vk}
    }
  }
  rule initialize_msgTags {
    select when edge new_messages vk re#(.+)# setting(vk)
      where ent:msgTags{vk}.isnull()
    fired {
      ent:msgTags{vk} := []
    }
  }
  rule process_each_message {
    select when edge new_messages
    foreach event:attr("messages") setting(x)
    pre {
      vk = event:attr("vk")
      eci = event:attr("eci")
      message = x.decode()
    }
    if not (ent:msgTags{vk} >< message{"tag"}) then
      event:send({"eci":eci,
        "domain":"sovrin", "type": "new_message",
        "attrs": message
          .put(["need_router_connection"],true)
      })
    fired {
      ent:msgTags{vk} := ent:msgTags{vk}.append(message{"tag"})
    }
  }
  rule poll_at_system_startup {
    select when system online
             or edge poll_all_needed
    foreach ent:routerConnections.keys() setting(extendedLabel)
    pre {
      label = extendedLabel.extract(re#(.+) to .+#).head()
    }
    if label then send_directive("polling",{"label":label})
    fired {
      raise edge event "poll_needed" attributes {"label":label}
    }
  }
//
// clean up internal data structures as needed
//
  rule clean_up_router_connection {
    select when edge router_connection_deletion_requested
      label re#(.+)# setting(label)
    pre {
      extendedLabel = label + " to " + wrangler:name()
      vk = ent:routerConnections{[extendedLabel,"their_vk"]}
      eci = ent:routerConnections{[extendedLabel,"my_did"]}
      ok = ent:routerHost && eci
      url = <<#{ent:routerHost}/sky/event/#{eci}/cleanup/router/router_connection_deletion_requested>>
    }
    if ok then every {
      http:post(url,qs={"vk":vk}) setting(response)
      send_directive("router connection deleted",{"vk":vk,"response":response})
    }
    fired {
      clear ent:routerConnections{extendedLabel};
      raise edge event "router_connection_deleted";
    }
  }
  rule remove_router {
    select when edge router_removal_requested
      or wrangler rulesets_need_to_cleanup
      where ent:routerHost && ent:routerName
    pre {
      extendedLabel = ent:routerName + " to " + wrangler:name()
      ok = ent:routerConnections >< extendedLabel
        && ent:routerConnections.keys().length() == 1
    }
    if ok then noop()
    fired {
      raise wrangler event "channel_deletion_requested"
        attributes {"name":extendedLabel} if wrangler:channel(extendedLabel);
      raise edge event "router_connection_deletion_requested"
        attributes {"label":ent:routerName};
    }
  }
  rule remove_this_ruleset {
    select when edge router_connection_deleted
      where ent:routerConnections.keys().length() == 0
    fired {
      raise wrangler event "uninstall_rulesets_requested"
        attributes {"rid":meta:rid};
    }
  }
}
