ruleset G2S.indy_sdk.wallet {
  meta {
    description <<
      Wallet Module,
      use example, use module G2S.indy_sdk.wallet alias wallet.
      This Ruleset/Module provides...
    >>
    shares __testing, walletHandle, listDids
  }
  global {
    wallet={}
    __testing = { "queries":
      [ { "name": "walletHandle" },{"name":"listDids","args":["walletHandle"]}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "wallet", "type": "open", "attrs":["walletName","key"] },
      { "domain": "wallet", "type": "newDid", "attrs":["walletHandle","did","seed","crypto_type","cid"] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    walletHandle = function(){
      wallet:walletHandles()
      //wallet{"handle"}
    }
    listDids = function(walletHandle){
      wallet:listMyDidsWithMeta(walletHandle)
    }
  }
    rule openWallet {
    select when wallet open
      wallet:openWallet({"id" : event:attr("walletName")},
                          {"key": event:attr("key")} ) setting(WalletHandle)
  }
  rule newDid {
    select when wallet newDid
    pre{
      config    = event:attr("did") => {}.put("did",event:attr("did").as("Number")) | {}
      _config   = event:attr("seed") => config.put("seed", event:attr("seed")) | config
      __config  = event:attr("crypto_type") => _config.put("crypto_type", event:attr("crypto_type")) | _config
      ___config = event:attr("cid") => __config.put("cid", event:attr("cid")) | __config
    }
      wallet:createAndStoreMyDid(event:attr("walletHandle"), ___config ) setting(didVerkey)

  }
}
