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
    routerURL = <<#{ent:routerHost}/sky/cloud/#{routerECI}/org.sovrin.router/stored_msg>>
    get_msg = function(vk){
      http:get(routerURL,qs={"vk":vk})
    }
    routerRequestURL = <<#{ent:routerHost}/sky/event/#{ent:routerRequestECI}/null/router/request>>
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
  rule poll_for_messages {
    select when edge poll_needed vk re#(.+)# setting(vk)
    pre {
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
