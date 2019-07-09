ruleset org.sovrin.edge {
  meta {
    use module io.picolabs.wrangler alias wrangler
    shares __testing, get_vk, get_did, get_msg
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "get_vk", "args": [ "did" ] }
      , { "name": "get_did", "args": [ "vk" ] }
      , { "name": "get_msg", "args": [ "vk" ] }
      ] , "events":
      [ { "domain": "edge", "type": "poll_needed", "attrs": [ "vk" ] }
      , { "domain": "edge", "type": "new_router", "attrs": [ "host", "eci" ] }
      , { "domain": "edge", "type": "need_router_connection", "attrs": [ "label" ] }
      ]
    }
    get_vk = function(did){
      wrangler:channel(did || meta:eci){["sovrin","indyPublic"]}
    }
    get_did = function(vk){
      wrangler:channel()
        .filter(function(x){x{["sovrin","indyPublic"]} == vk})
        .head(){"id"}
    }
    routerECI = "HvuJ6u7b5jrwJkXhndwsiX"
    get_msg = function(vk){
      routerURL = <<#{ent:routerHost}/sky/cloud/#{routerECI}/org.sovrin.router/stored_msg>>;
      http:get(routerURL,qs={"vk":vk})
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
    }
    every {
      wrangler:createChannel(meta:picoId,label,"router")
        setting(channel)
      http:post(routerRequestURL,qs={
        "final_key":channel{["sovrin","indyPublic"]},
        "label":label,
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
    }
  }
  rule poll_for_messages {
    select when edge poll_needed vk re#(.+)# setting(vk)
    pre {
      routerURL = <<#{ent:routerHost}/sky/cloud/#{routerECI}/org.sovrin.router/stored_msg>>
      eci = get_did(vk)
      res = eci => http:get(routerURL,qs={"vk":vk}) | {}
    }
    if eci && res{"status_code"} == 200 then
      event:send({"eci":eci, "domain":"sovrin", "type": "new_message",
        "attrs": res{"content"}.decode()
          .put(["routerRequestURL"],routerRequestURL)
      })
  }
}
