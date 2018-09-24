ruleset G2S.indy_sdk.pool {
  meta {
    shares __testing, listPools, poolHandle
  }
  global {
    Pool={}
    __testing = { "queries":
      [ { "name": "listPools" },{"name":"poolHandle"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "pool", "type": "open" , "attrs": ["poolName"]}
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    listPools= function(){
      indy_sdk:listPool();
    }
    poolHandle= function(){
      indy_sdk:poolHandle();
      //Pool{"handle"}//.defaultsTo("")
    }
  }   
  rule openPool {
    select when pool open
      indy_sdk:openPool(event:attr("poolName")) setting(poolHandle)
    always{
      Pool.put(["handle"],poolHandle)
    }
  }

}
