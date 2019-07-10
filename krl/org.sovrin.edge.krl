ruleset org.sovrin.edge {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module org.sovrin.agent_message alias a_msg
    shares __testing, get_vk, get_did, invitation_via
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "get_vk", "args": [ "label" ] }
      , { "name": "get_did", "args": [ "vk" ] }
      , { "name": "invitation_via", "args": [ "label" ] }
      ] , "events":
      [ { "domain": "edge", "type": "new_router", "attrs": [ "host", "eci" ] }
      , { "domain": "edge", "type": "need_new_router_connection", "attrs": [ "label" ] }
      , { "domain": "edge", "type": "poll_needed", "attrs": [ "label" ] }
      ]
    }
    get_vk = function(label){
      extendedLabel = label + " to " + wrangler:name();
      ent:routerConnections.defaultsTo({}){[extendedLabel,"their_vk"]}
    }
    get_did = function(vk){
      wrangler:channel()
        .filter(function(x){x{["sovrin","indyPublic"]} == vk})
        .head(){"id"}
    }
    invitation_via = function(label){
      extendedLabel = label + " to " + wrangler:name();
      eci = ent:routerConnections.defaultsTo({}){[extendedLabel,"my_did"]};
      routing = ent:routerConnections.defaultsTo({}){[extendedLabel,"their_routing"]};
      endpoint = <<#{ent:routerHost}/sky/event/#{eci}/null/sovrin/new_message>>;
      i = a_msg:connInviteMap(null,wrangler:name(),get_vk(label),endpoint,routing);
      <<#{ent:routerHost}/sky/cloud/#{eci}/org.sovrin.agent/html.html>>
        + "?c_i=" + math:base64encode(i.encode())
    }
  }
  rule edge_new_router {
    select when edge new_router
      host re#(https?://.+)#
      eci re#(.+)#
      setting(host,eci)
    fired {
      ent:routerHost := host;
      ent:routerRequestECI := eci
    }
  }
//
// router connection with a new channel
//
  rule make_new_router_connection {
    select when edge need_new_router_connection
      label re#(.+)# setting(label)
    pre {
      extendedLabel = label + " to " + wrangler:name()
    }
    wrangler:createChannel(meta:picoId,extendedLabel,"router")
      setting(channel)
    fired {
      raise edge event "need_router_connection" attributes {
        "channel": channel,
        "label": label,
      }
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
      ent:routerConnections := ent:routerConnections.defaultsTo({})
        .put([connection{"label"}],connection);
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
      other_eci = ent:routerConnections.defaultsTo({}){[extendedLabel,"my_did"]}
      url = <<#{ent:routerHost}/sky/cloud/#{other_eci}/org.sovrin.router/stored_msg>>
      vk = get_vk(label)
      eci = vk => get_did(vk) | null
      res = eci => http:get(url,qs={"vk":vk}) | {}
      messages = res{"status_code"} == 200 => res{"content"}.decode() | null
    }
    if vk && eci && messages then noop()
    fired {
      raise edge event "new_messages" attributes {
        "messages":messages, "eci": eci, "vk": vk}
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
    if not (ent:msgTags{vk}.defaultsTo([]) >< message{"tag"}) then
      event:send({"eci":eci,
        "domain":"sovrin", "type": "new_message",
        "attrs": message
          .put(["need_router_connection"],true)
      })
    fired {
      ent:msgTags{vk} := ent:msgTags{vk}.defaultsTo([]).append(message{"tag"})
    }
  }
  rule poll_at_system_startup {
    select when system online
    foreach ent:routerConnections.keys() setting(extendedLabel)
    pre {
      label = extendedLabel.extract(re#(.+) to .+#).head()
    }
    if label then send_directive("polling",{"label":label})
    fired {
      raise edge event "poll_needed" attributes {"label":label}
    }
  }
}
