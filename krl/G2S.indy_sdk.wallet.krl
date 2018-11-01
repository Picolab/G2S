ruleset G2S.indy_sdk.wallet {
  meta {
    description <<
      Wallet Module,
      use example, use module G2S.indy_sdk.wallet alias wallet.
      This Ruleset/Module provides...
    >>
    shares __testing, wallets, listDids,openWalletFun, openWallet, closeWallet,createWallet,newDid,openWalletFun,closeWalletFun,deleteWallet
    provides __testing, wallets, listDids,openWalletFun, openWallet, closeWallet,createWallet,newDid,openWalletFun,closeWalletFun,deleteWallet
  }
  global {
    wallet={}
    __testing = { "queries":
      [ { "name": "wallets" },{"name":"listDids","args":["walletHandle"]},
        {"name":"openWalletFun"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "wallet", "type": "open", "attrs":["walletName","key"] },
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
    
    createWallet = defaction(id,key,storage_type,storage_config,path ) {
      config    = id => {}.put("id",id) | {}
      _config   = storage_type => config.put("storage_type", storage_type) | config
      __config  = storage_config => _config.put("storage_config", storage_config) | _config
      ___config = path => __config.put("path", path) | __config
      credentials = {"key": key}
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
      wallet:createAndStoreMyDid(walletHandle, ___config.klog("config for did: ") ) setting(didVerkey)
      wallet:setDidMetadata(walletHandle,didVerkey[0],metaData)
      send_directive("DID created with",  {"walletHandle":walletHandle,"config":___config, "didVerkey":didVerkey});
      }
      returns didVerkey
    }
    //deleteDid = defaction(){
      //noop()
    //}
    
    openWalletFun = function(id,key){
      wallet:openWalletFunction({"id" : id},{"key":key} )
    }
    closeWalletFun = function(wallet_handle){
      wallet:closeWalletFunction(wallet_handle)
    }
    openWallet = defaction(id,key){
      wallet:openWalletAction({"id" : id},{"key":key} ) setting(handle)
      returns handle
    }
    closeWallet = defaction(wallet_handle){
      wallet:closeWalletAction(wallet_handle)
    }
    deleteWallet = defaction(id,key,storage_type,storage_config,path ){
      config    = id => {}.put("id",id) | {}
      _config   = storage_type => config.put("storage_type", storage_type) | config
      __config  = storage_config => _config.put("storage_config", storage_config) | _config
      ___config = path => __config.put("path", path) | __config
      credentials = {"key": key}
      every{
          wallet:deleteWallet(___config,credentials) setting(results)
          send_directive("wallet deleted with",  {"config":___config, "credentials":credentials, "results":results});
      }
        returns results
      
    }

  }
  
  rule createWallet {
    select when wallet create
      createWallet(event:attr("name"),event:attr("key"),event:attr("storage_type"),event:attr("storage_config"),event:attr("path"))
  }
  
  rule openWallet {// open wallet is now a function
    select when wallet open
      openWallet(event:attr("walletName"),event:attr("key")) setting(WalletHandle)
  }
  rule closeWallet {
    select when wallet close
      closeWallet(event:attr("handle"))
  }
  rule newDid {
    select when wallet newDid
      newDid(event:attr("walletHandle"),event:attr("did"),event:attr("seed"),event:attr("crypto_type"),event:attr("cid"),event:attr("metaData"))
  }
}
