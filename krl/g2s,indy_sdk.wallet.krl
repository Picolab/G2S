ruleset G2S.indy_sdk.wallet {
  meta {
    shares __testing, walletHandle
  }
  global {
    wallet={}
    __testing = { "queries":
      [ { "name": "walletHandle" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "wallet", "type": "open", "attrs":["walletName","key"] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    walletHandle = function(){
      indy_sdk:walletHandle()
      //wallet{"handle"}
    }
  }
    rule openPool {
    select when wallet open
      indy_sdk:openWallet({"id" : event:attr("walletName")},
                          {"key": event:attr("key")} ) setting(WalletHandle)
    always{
      wallet.put(["handle"],poolHandle)
    }
  }
}
