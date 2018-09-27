ruleset G2S.indy_sdk.ledger {
  meta {
    shares __testing, getNym
  }
  global {
    __testing = { "queries":
      [ { "name": "getNym","args":["poolHandle","submitterDid","targetDid"] }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
        { "domain": "ledger", "type": "nym", "attrs": [ "poolHandle", 
                                                        "signing_did",
                                                        "anchoring_did",
                                                        "anchoring_did_verkey",
                                                        "alias",
                                                        "role",
                                                        "walletHandle"] }
      ]
    }
    getNym = function(poolHandle,submitterDid,targetDid){
      request = ledger:buildGetNymRequest(submitterDid,targetDid);
      ledger:submitRequest(poolHandle,request)
    }
    
    nym = defaction(pool_handle,signing_did,anchoring_did,anchoring_did_verkey,alias,role,wallet_handle){
      request = ledger:buildNymRequest(signing_did,
                               anchoring_did,
                               anchoring_did_verkey,
                               alias,
                               role)
      response = ledger:signAndSubmitRequest(pool_handle,
                                    signing_did,
                                    wallet_handle,
                                    request)                         
      send_directive("nym transaction");
      returns response
    }
    
  }
  rule nym {
    select when ledger nym
    nym(event:attr("poolHandle"),
        event:attr("signing_did"),
        event:attr("anchoring_did"),
        event:attr("anchoring_did_verkey"),
        event:attr("alias"),
        event:attr("role"),
        event:attr("walletHandle"))
  }
}
