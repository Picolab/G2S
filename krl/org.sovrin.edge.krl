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
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
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
    routerHost = "https://manifold.picolabs.io:9090"
    routerECI = "HvuJ6u7b5jrwJkXhndwsiX"
    routerURL = <<#{routerHost}/sky/cloud/#{routerECI}/org.sovrin.router/stored_msg>>
    get_msg = function(vk){
      http:get(routerURL,qs={"vk":vk})
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
      })
  }
}
