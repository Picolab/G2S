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
      , { "domain": "edge", "type": "need_router_connection", "attrs": [ "label" ] }
      , { "domain": "edge", "type": "poll_needed", "attrs": [ "label" ] }
      ]
    }
    get_vk = function(label){
      extendedLabel = label + " to " + wrangler:name();
      vk1 = ent:routerConnections.defaultsTo({}){[extendedLabel,"their_vk"]};
      vk2 = wrangler:channel(extendedLabel){["sovrin","indyPublic"]};
      vk1 && vk2 && vk1 == vk2 => vk1 | null
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
  rule make_router_connection {
    select when edge need_router_connection
      label re#(.+)# setting(label)
    pre {
      routerRequestURL = <<#{ent:routerHost}/sky/event/#{ent:routerRequestECI}/null/router/request>>
      extendedLabel = label + " to " + wrangler:name()
    }
    every {
      wrangler:createChannel(meta:picoId,extendedLabel,"router")
        setting(channel)
      http:post(routerRequestURL,qs={
        "final_key":channel{["sovrin","indyPublic"]},
        "label":extendedLabel,
      }) setting(response)
    }
    fired {
      raise edge event "new_router_connection" attributes response.decode()
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
    }
    if ok && connection{"label"} then noop()
    fired {
      ent:routerConnections := ent:routerConnections.defaultsTo({})
        .put([connection{"label"}],connection)
    } else {
      ent:failedResponse := event:attrs
    }
  }
  rule poll_for_messages {
    select when edge poll_needed label re#(.+)# setting(label)
    pre {
      extendedLabel = label + " to " + wrangler:name();
      other_eci = ent:routerConnections.defaultsTo({}){[extendedLabel,"my_did"]}
      url = <<#{ent:routerHost}/sky/cloud/#{other_eci}/org.sovrin.router/stored_msg>>
      vk = get_vk(label)
      eci = vk => get_did(vk) | null
      res = eci => http:get(url,qs={"vk":vk}) | {}
      message = res{"status_code"} == 200 => res{"content"}.decode() | null
    }
    if vk && eci && message then
      event:send({"eci":eci, "domain":"sovrin", "type": "new_message",
        "attrs": message
          .put(["routingInfo"],{
            "endpoint": <<#{ent:routerHost}/sky/event/#{other_eci}/null/sovrin/new_message>>,
            "routing": ent:routerConnections.defaultsTo({}){[extendedLabel,"their_routing"]}
          })
      })
  }
}
