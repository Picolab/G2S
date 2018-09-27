ruleset G2S.indy_sdk.pool {
  meta {
    shares __testing, listPools, pool
  }
  global {
    Pool={}
    __testing = { "queries":
      [ { "name": "listPools" },{"name":"pool"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "pool", "type": "open" , "attrs": ["poolName"]}
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    listPools= function(){
      pool:listPool();
    }
    pool= function(){
      pool:poolHandle();
      //Pool{"handle"}//.defaultsTo("")
    }
  }   
  rule openPool {
    select when pool open
      pool:openPool(event:attr("poolName")) setting(poolHandle)
    always{
      Pool.put(["handle"],poolHandle)
    }
  }

}
