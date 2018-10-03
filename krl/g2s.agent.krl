ruleset G2S.agent {
  meta {
    shares __testing, ephemeralDids, dids
    provides ephemeralDids, dids
    //provides
    use module G2S.indy_sdk.wallet alias wallet_module
    use module io.picolabs.wrangler alias wrangler 
    
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }, {"name":"ephemeralDids"},{"name":"dids"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "agent", "type": "create_ephemeral_did" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    id = function(){
      wrangler:myself(){"id"}
    }
    ephemeralDids = function(){
      ent:single_use_dids
    }
    dids = function(){
        handle = openWalletFun();
        dids = wallet_module:listDids(handle);
        closeWalletFun(handle);
        dids
    }
    openWalletFun = function(){
      wallet_module:openWalletFun(id(),id())
    }
    closeWalletFun = function(wallet_handle){
      wallet_module:closeWalletFun(wallet_handle)
    }
    openWallet = defaction(){
      wallet_module:openWallet(id(),id()) setting(handle)
      returns handle
    }
    closeWallet = defaction(wallet_handle){
      wallet_module:closeWallet(wallet_handle)
    }
    newDid = defaction(did,seed,meta_data){
      every{
        openWallet() setting(handle)
        wallet_module:newDid(handle.klog("handle"), null, null, null, null,meta_data) setting(did_verkey)
        closeWallet(handle)
      }
      returns did_verkey
    }
    createEphemeralDid = defaction(){
      every{
        openWallet() setting(handle)
        wallet_module:newDid(handle.klog("handle"), null, null, null, null,"single use") setting(did_verkey)
        closeWallet(handle)
      }
      returns did_verkey
    }
  }
  rule constructor {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre{}
    //if() then // should check to see if wallet exists.... but indy-sdk does not support this. 
    wallet_module:createWallet(id(),id(),null,null,null )
    always{
      ent:single_use_dids := []
    }
  }
  rule createEphemeralDid {
    select when agent create_ephemeral_did
      createEphemeralDid() setting(did_verkey)
      always{
        ent:single_use_dids := ent:single_use_dids.append(did_verkey)
      }
  }
  
}
