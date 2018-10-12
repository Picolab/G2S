ruleset G2S.agent {
  meta {
    shares __testing, ephemeralDids, dids,credentialDefinition,credentialDefinitions,credentialOffer,createLinkSecret,linkSecretId,getNym
    provides ephemeralDids, dids,credentialDefinition,credentialDefinitions,credentialOffer,createLinkSecret,linkSecretId,getNym
    //provides
    use module G2S.indy_sdk.wallet alias wallet_module
    use module io.picolabs.subscription alias subscription
    use module G2S.indy_sdk.ledger alias ledger_module
    use module G2S.indy_sdk.pool   alias pool_module
    use module io.picolabs.wrangler alias wrangler 
    
  }
  global {
    wellknown_Policy = { // we need to restrict what attributes are allowed on this channel, specifically Id.
      "name": "agent_wellknown",
      "event": {
          "allow": [
              {"domain": "wrangler", "type": "subscription"},
              {"domain": "wrangler", "type": "new_subscription_request"},
              {"domain": "wrangler", "type": "inbound_removal"}
          ]
      }
    }
    __testing = { "queries":
      [ { "name": "__testing" }, /*{"name":"ephemeralDids"},*/{"name":"dids"},{"name":"credentialDefinition","args":["submitterDid", "id"]},{"name":"credentialDefinitions"},
        {"name":"credentialOffer","args":["cred_def_id"]},{"name":"credentialRequest","args":["prover_did","cred_offer","cred_def"]},{"name":"linkSecretId"},
        { "name": "getNym","args":["submitterDid","targetDid"] }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "agent", "type": "create_ephemeral_did" },
        { "domain": "agent", "type": "create_did", "attrs":["did","seed","meta_data"] },
        { "domain": "agent", "type": "create_credential_definition", "attrs":["issuer_did","name","version","attrNames","tag"] },
        { "domain": "agent", "type": "nym", "attrs": [ "signing_did",
                                                        "anchoring_did",
                                                        "anchoring_did_verkey",
                                                        "alias",
                                                        "role"] }
      , { "domain": "agent", "type": "create_secret"}, { "domain": "agent", "type": "connect","attrs":["destination_did"]}
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
      returns handle.klog("open wallet")
    }
    closeWallet = defaction(wallet_handle){
      wallet_module:closeWallet(wallet_handle)
    }
    
    getNym = function(submitterDid,targetDid){
      request = ledger:buildGetNymRequest(submitterDid,targetDid);
      ledger:submitRequest(pool_module:handle(),request);
    }
    
    newDid = defaction(did, seed, crypto_type, cid,meta_data){
      every{
        openWallet() setting(handle)
        wallet_module:newDid(handle, did, seed, crypto_type, cid,meta_data) setting(did_verkey)
        closeWallet(handle)
      }
      returns did_verkey
    }
    
    newNym = defaction(signing_did,anchoring_did,anchoring_did_verkey,alias,role){
      every{
      openWallet() setting(wallet_handle)
      ledger_module:nym(pool_module:handle(),signing_did,anchoring_did,anchoring_did_verkey,alias,role,wallet_handle.klog(walletHandle)) setting(results)
      closeWallet(wallet_handle)
      }
      returns results
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
    /*anchorSchema = function(issuerDid,name,version,attrNames){// todo
        handle = openWalletFun();
        results = ledger_module:anchorSchema(pool_module:handle(),handle,issuerDid,issuerDid,name,version,attrNames).klog("returned schema id");
        closeWalletFun(handle);
        results
    }
    defineCredential = defaction(issuer_did,schema_id){// todo
      id_schema_schema = ledger_module:getSchema(pool_module:handle(),issuer_did,schema_id)
      every{
        openWallet() setting(handle)
        ledger_module:anchorCredDef(pool_module:handle(),wallet_handle, issuer_did,id_schema_schema[1],tag, signature_type, cred_def_config)
        closeWallet(handle)
      }
    }*/
    credentialDefinition = function(submitterDid, id){
      ledger_module:credDefs(pool_module:handle(),submitterDid, id)
    }
    credentialDefinitions = function(){
      ent:cred_defs
    }
    createCredentialDefinition = defaction(issuer_did,name,version,attrNames,tag, signature_type, cred_def_config){
        handle = openWalletFun()
        results = ledger_module:anchorSchema(pool_module:handle(),handle.klog("walletHandle1"),issuer_did,issuer_did,name,version,attrNames.decode().klog("attr names")).klog("returned anchor schema in agent");
        id_schema_schema = ledger_module:getSchema(pool_module:handle(),issuer_did,results{"result"}{"txnMetadata"}{"txnId"}.klog("schemaid")).klog("getschema ");// can we skip this step and use schema from above?
        every{
          ledger_module:anchorCredDef(pool_module:handle(),handle, issuer_did,id_schema_schema[1].klog("schema"),tag, signature_type, cred_def_config)setting(results);
          closeWallet(handle);
        }
        returns results
    }
    credentialOffer = function(cred_def_id){
      handle = openWalletFun();
      offer = ledger_module:issuerCreateCredentialOffer(handle,cred_def_id);
      closeWalletFun(handle);
      offer
    }
    createLinkSecret = defaction(link_secret_id){
      every{openWallet()setting(handle);
      ledger_module:createLinkedSecret(handle, link_secret_id)setting(results);
      closeWallet(handle);
      }
      returns results
    }
    linkSecretId = function(){
      ent:secret_id
    }
    credentialRequest = function(prover_did,cred_offer,cred_def){
      handle = openWalletFun();
      results = proverCreateCredentialReq (handle ,prover_did,cred_offer,cred_def,ent:secret_id);
      closeWalletFun(handle);
      results
    }
    proofRequest = defaction(){
      noop()
    }
    initiate_subscription = defaction(eci) {
      every{
        event:send({
          "eci": eci, "eid": "subscription",
          "domain": "wrangler", "type": "subscription",
          "attrs": {
                   "Rx_role"     : "agent",
                   "Tx_role"     : "agent",
                   "Tx_Rx_Type"  : "Indy" , // auto_accept
                   "channel_type": "Indy",
                   "wellKnown_Tx": subscription:wellKnown_Rx(){"id"} 
                   } 
        })
      }
    }
    
    
  }
  rule constructor {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre{}
    //if() then // should check to see if wallet exists.... but indy-sdk does not support this. 
      every{
        wallet_module:createWallet(id(),id(),null,null,null )
        createLinkSecret(null)setting(secretId)
      }
    always{
      ent:single_use_dids := [];// todo: remove this ....
      ent:secret_id:= secretId;
      raise wrangler event "autoAcceptConfigUpdate"
        attributes {"variable"    : "Tx_Rx_Type",
                    "regex_str"   : "Indy" };
    }
  }
  rule create_wellKnown_Rx {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre{ channel = subscription:wellKnown_Rx() }
    if(channel.isnull() || channel{"type"} != "Tx_Rx") then every{
      wrangler:newPolicy(wellknown_Policy) setting(__wellknown_Policy)
      wrangler:createChannel(meta:picoId, "wellKnown_Rx", "Tx_Rx", __wellknown_Policy{"id"})
    }
    fired{
      raise wrangler event "wellKnown_Rx_created" attributes event:attrs;
      ent:wellknown_Policy := __wellknown_Policy;
    }
    //else{
    //  raise wrangler event "wellKnown_Rx_not_created" attributes event:attrs; //exists
    //}
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
  //rule deleteDid {// not supported in indy-sdk
  //  select when agent delete_did or wrangler channel_deleted
  //    deleteDid(event:attr("did").defaultsTo()) setting(did_verkey)
  //    always{
        //ent:dids := ent:dids.splice(index,index)
  //    }
  //}
  rule createCredentialDefinition {
    select when agent create_credential_definition
      createCredentialDefinition(event:attr("issuer_did"), // for schema
                                 event:attr("name"),// for schema
                                 event:attr("version"), // schema
                                 event:attr("attrNames"), // schema
                                 event:attr("tag"), 
                                 event:attr("signature_type").defaultsTo("CL"), 
                                 event:attr("cred_def_config").defaultsTo({"support_revocation": false}.encode()))setting(cred_def)
      always{
        ent:cred_defs := ent:cred_defs.append([cred_def.klog("cred_def results")])
      }
  }
  rule nym {
    select when agent nym
    newNym(event:attr("signing_did"),
        event:attr("anchoring_did"),
        event:attr("anchoring_did_verkey"),
        event:attr("alias"),
        event:attr("role")
        )
  }
  rule linkSecret {// Todo, add directives.
    select when agent create_secret
    if(ent:secret_id.isnull())then
       createLinkSecret(null) setting(secretId)
    fired{ent:secret_id:= secretId}
  }
  rule connection {
    select when agent connect
    initiate_subscription(event:attr("destination_did"))
  }
  
}
