ruleset G2S.indy_sdk.pool {
  meta {
    shares __testing, list, handle,create
    provides list, handle, create
  }
  global {
    __testing = { "queries":
      [ { "name": "list" },{"name":"handle"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "pool", "type": "open"  , "attrs": ["name"]},
        { "domain": "pool", "type": "close" , "attrs": ["handle"]},
        { "domain": "pool", "type": "create" , "attrs": ["name","config"]},
        { "domain": "pool", "type": "delete" , "attrs": ["handle"]}
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    list= function(){
      pool:listPool().map(function(value) {value{"pool"}});
    }
    handle= function(){
      pool:poolHandle();
    }
    create= defaction(){
      noop()
    }
  }
  rule create {
    select when pool create
      pool:createPool(event:attr("name"),event:attr("config")) 
  }
  rule open {
    select when pool open
      pool:openPool(event:attr("name")) setting(poolHandle)
  }
  rule close {
    select when pool close
      pool:closePool(event:attr("handle"))
  }
  rule delete {
    select when pool delete
      pool:deletePool(event:attr("handle"))
  }
}
