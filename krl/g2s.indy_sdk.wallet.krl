ruleset G2S.indy_sdk.wallet {
  meta {
    description <<
      Wallet Module,
      use example, use module G2S.indy_sdk.wallet alias wallet.
      This Ruleset/Module provides...
    >>
    shares __testing, wallets, listDids
  }
  global {
    wallet={}
    __testing = { "queries":
      [ { "name": "wallets" },{"name":"listDids","args":["walletHandle"]}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "wallet", "type": "open", "attrs":["walletName","key"] },
      { "domain": "wallet", "type": "newDid", "attrs":["walletHandle","did","seed","crypto_type","cid","metaData"] }
      , { "domain": "wallet", "type": "create", "attrs": [ "name", "key" ] }
      , { "domain": "wallet", "type": "close", "attrs": [ "handle" ] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    wallets = function(){
      wallet:walletHandles()
      //wallet{"handle"}
    }
    listDids = function(walletHandle){
      wallet:listMyDidsWithMeta(walletHandle)
    }
    
    createWallet = defaction(name,storage_type,storage_config,path ) {
      config    = name => {}.put("id",name) | {}
      _config   = storage_type => config.put("storage_type", storage_type) | config
      __config  = storage_config => _config.put("storage_config", storage_config) | _config
      ___config = path => __config.put("path", path) | __config
      credentials = {"key": event:attr("key")}
      every{
          wallet:createWallet(___config,credentials) setting(walletHandle)
          send_directive("wallet created with",  {"config":___config, "credentials":credentials, "walletHandle":walletHandle});// should directives be in defactions?
      }
        returns walletHandle
    }
    
    newDid = defaction(walletHandle, did, seed, crypto_type, cid,metaData){
       config   = did => {}.put("did",did) | {}
      _config   = seed => config.put("seed", seed) | config
      __config  = crypto_type => _config.put("crypto_type", crypto_type) | _config
      ___config = cid => __config.put("cid", cid) | __config
      every{
      wallet:createAndStoreMyDid(walletHandle, ___config ) setting(didVerkey)
      wallet:setDidMetadata(walletHandle,didVerkey[0],metaData)
      send_directive("DID created with",  {"walletHandle":walletHandle,"config":___config, "didVerkey":didVerkey});
      }
      returns didVerkey
    }
  }
  
  rule createWallet {
    select when wallet create
      createWallet(event:attr("name"),event:attr("storage_type"),event:attr("storage_config"),event:attr("path"))
  }
  
  rule openWallet {
    select when wallet open
      wallet:openWallet({"id" : event:attr("walletName")},{"key": event:attr("key")} ) setting(WalletHandle)
  }
  rule closeWallet {
    select when wallet close
      wallet:closeWallet(event:attr("handle"))
  }
  rule newDid {
    select when wallet newDid
      newDid(event:attr("walletHandle"),event:attr("did"),event:attr("seed"),event:attr("crypto_type"),event:attr("cid"),event:attr("metaData"))
  }
}
