ruleset G2S.agent {
  meta {
    shares __testing, ephemeralDids, dids
    provides ephemeralDids, dids
    //provides
    use module G2S.indy_sdk.wallet alias wallet_module
    use module G2S.indy_sdk.ledger alias ledger_module
    use module io.picolabs.wrangler alias wrangler 
    
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }, {"name":"ephemeralDids"},{"name":"dids"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "agent", "type": "create_ephemeral_did" },
        { "domain": "agent", "type": "create_did", "attrs":["did","seed","meta_data"] }
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
    newDid = defaction(did, seed, crypto_type, cid,meta_data){
      every{
        openWallet() setting(handle)
        wallet_module:newDid(handle, did, seed, crypto_type, cid,meta_data) setting(did_verkey)
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
    //deleteDid = defaction(){
    //  noop()
    //}
    anchorSchema = defaction(){
      every{
        openWallet() setting(handle)
        ledger_module:anchorSchema(pool_handle,handle,submitter_did,issuerDid,name,version,attrNames)
        closeWallet(handle)
      }
    }
    defineCredential = defaction(){
      id_schema = ledger_module:getSchema(pool_handle,submitter_did,data)
      every{
       ledger_module:anchorCredDef(pool_handle,wallet_handle, issuer_did,data,tag, signature_type, cred_def_config)
      }
    }
    credentialOffer = function(){
      
    }
    credentialRequest = function(){
      
    }
    proofRequest = defaction(){
      noop()
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
        ent:single_use_dids := ent:single_use_dids.append([did_verkey])
      }
  }
  rule createDid {
    select when agent create_did
      newDid(event:attr("did"),event:attr("seed"),event:attr("crypto_type"), event:attr("cid"),event:attr("meta_data")) setting(did_verkey)
      always{
        ent:dids := ent:dids.append([did_verkey])
      }
  }
  rule duplicateDid {
    select when wrangler channel_created
      newDid(event:attr("channel"){"id"}.klog("channel Id "),null,null,null,{}.put("name",event:attr("channel"){"name"})
                                                .put("type",event:attr("channel"){"type"})
                                                .put("policy_id",event:attr("channel"){"policy_id"}).encode()) setting(did_verkey)
      always{
        ent:dids := ent:dids.append([did_verkey])
      }
  }
  //rule deleteDid {
  //  select when agent delete_did or wrangler channel_deleted
  //    deleteDid(event:attr("did").defaultsTo()) setting(did_verkey)
  //    always{
        //ent:dids := ent:dids.splice(index,index)
  //    }
  //}
  
}
