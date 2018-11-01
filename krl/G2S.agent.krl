ruleset G2S.agent {
  meta {
    shares __testing, ephemeralDids, dids,credentialDefinition,connections,
      credentialDefinitions,credentialOffer,createLinkSecret,linkSecretId,getNym,nymRequests,credentialRequest,createCredential,proofRequest
    provides ephemeralDids, dids,credentialDefinition,credentialDefinitions,connections,
      credentialOffer,createLinkSecret,linkSecretId,getNym,nymRequests,credentialRequest,createCredential,proofRequest
    //provides
    use module G2S.indy_sdk.wallet alias wallet_module
    use module io.picolabs.subscription alias subscription
    use module G2S.indy_sdk.ledger alias ledger_module
    use module G2S.indy_sdk.pool   alias pool_module
    use module io.picolabs.wrangler alias wrangler 
    
  }
  global {
    /*TODO:
    did_doc{ pairwise_did: ... ,routing:[agency_did, ... ,cloud_did,edge_did]
    */
    // subscription code can be removed after subscription fix is merged into production.
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
        { "name": "getNym","args":["submitterDid","targetDid"] },{"name":"createCredential","args":["credOffer", "credReq", "credValues", "revRegId", "blobStorageReaderHandle"]},
        {"name":"storeCredential","args":["credId", "credReqMetadata", "cred", "credDef", "revRegDef"]},
        {"name":"proofRequest","args":[ "name", "version", "requested_attributes", "requested_predicates"]},
        {"name": "connections", "args":[]},{"name":"nymRequests","args":[]}
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
    dids = function(metaData){// TODO: add filter by did...
        handle = openWalletFun();
        dids = wallet_module:listDids(handle);
        results = metaData.isnull() => dids|dids.filter(function(did){did{"metadata"} == metaData }); 
        closeWalletFun(handle);
        results
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
    deleteWallet = defaction(id,key,storage_type,storage_config,path){
      wallet_module:deleteWallet(id,key,storage_type,storage_config,path)
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
    
    nymRequests = function(){
      ent:nym_requests
    }
    
    newNym = defaction(signing_did,anchoring_did,anchoring_did_verkey,alias,role){
      every{
      openWallet() setting(wallet_handle)
      ledger_module:nym(pool_module:handle(),signing_did,anchoring_did,anchoring_did_verkey,alias,role,wallet_handle) setting(results)
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
    
    credentialDefinition = function(submitterDid, id){
      ledger_module:credDefs(pool_module:handle(),submitterDid, id)
    }
    
    credentialDefinitions = function(){
      ent:cred_defs
    }
    
    createSchema = function(issuer_did,name,version,attrNames){
      handle = openWalletFun();
      results = ledger_module:anchorSchema(pool_module:handle(),handle,issuer_did,issuer_did,name,version,attrNames.decode());
      closeWalletFun(handle);
      results
    }
    
    createCredDef = defaction(schema_issuer_did,schemaid,issueing_did,tag, signature_type, cred_def_config){
      handle = openWalletFun()
      id_schema_schema = ledger_module:getSchema(pool_module:handle(), schema_issuer_did, schemaid, tag, signature_type, cred_def_config);
      every{
        ledger_module:anchorCredDef(pool_module:handle(),handle, issueing_did,id_schema_schema[1],tag, signature_type, cred_def_config)setting(results);
        closeWallet(handle);
      }
      returns results
    }
    
    createCredentialDefinition = defaction(issuer_did,name,version,attrNames,tag, signature_type, cred_def_config){
        handle = openWalletFun()
        results = ledger_module:anchorSchema(pool_module:handle(),handle.klog("walletHandle1"),issuer_did,issuer_did,name,version,attrNames.decode());
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
      results = ledger_module:proverCreateCredentialReq(handle ,prover_did,cred_offer,cred_def,ent:secret_id);
      closeWalletFun(handle);
      results
    }
    createCredential = function(credOffer, credReq, credValues, revRegId, blobStorageReaderHandle){
      handle = openWalletFun();
      results = ledger_module:createCred(handle, credOffer, credReq, credValues, revRegId, blobStorageReaderHandle);
      closeWalletFun(handle);
      results
    }
    storeCredential = defaction( credId, credReqMetadata, cred, credDef, revRegDef){
      every{
        openWallet()setting(handle);
        ledger_module:storeCred(handle, credId, credReqMetadata, cred, credDef, revRegDef)setting(results)
        closeWallet(handle);
      }
      returns results
    }
    proofRequest = function(nonce, name, version, requested_attributes, requested_predicates){
      {
        "nonce": nonce.defaultsTo(random:integer(9999999999999999999999999)),
        "name": name,
        "version": version,
        "requested_attributes": requested_attributes,
        "requested_predicates": requested_predicates
      }
    }
    credentialForRequest = function(){
      handle = openWalletFun();
      results = ledger_module:this;
      closeWalletFun(handle);
      results
    }
    searchForCredentialRequest = function(query){
      handle = openWalletFun();
      results = ledger_module:searchCredWithReq(handle,query);
      closeWalletFun(handle);
      results
    }
    
    initiate_subscription = defaction(eci,Rx_role, Tx_role ) {
      event:send({
        "eci": eci,
        "domain": "wrangler", "type": "subscription",
        "attrs": event:attrs.put({
                 "Rx_role"     : Rx_role.defaultsTo("agent"),
                 "Tx_role"     : Tx_role.defaultsTo("agent"),
                 "Tx_Rx_Type"  : "Indy" , // auto_accept
                 "channel_type": "Indy",
                 "wellKnown_Tx": subscription:wellKnown_Rx(){"id"} 
                 } )
      })
    }
    
    connections = function(){
      ent:connections
    }
    
    getSigning_did = function(){}//TODO: write this
    
    indexOfId = function(map, id) {
      map.map(function(value){
        value{"id"}
      }).index(id)
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
      ent:sent_nym_requests := {};
      ent:nym_requests := {};
      ent:sent_cred_offers := {};
      ent:sent_cred_request := {};
      ent:cred_offers := {};
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
  
  rule createSchema {
    select when agent create_schema
    pre{
      schema = createSchema(event:attr("issuer_did"),
                   event:attr("name"),
                   event:attr("version"),
                   event:attr("attrNames"))
    }
    every {
      send_directive("createSchema", schema);
    }
      always{
        app:schemas := app:schemas.append([schema])
      }
  }
  
  rule createCredDef {
    select when agent create_cred_def
    every{
      createCredDef(
               event:attr("schema_issuer_did"),
               event:attr("schema_id"),
               event:attr("issueing_did"),
               event:attr("tag"), 
               event:attr("signature_type").defaultsTo("CL"), 
               event:attr("cred_def_config").defaultsTo({"support_revocation": false}.encode()))setting(cred_def)
      send_directive("createCredDef", cred_def);
    }
      always{
        ent:cred_defs := ent:cred_defs.append([cred_def])
      }
  }
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
  rule sendCredentialOffer {
    select when agent send_credential_offer
    pre{
      id = random:uuid();
      offer = {"offer":credentialOffer(event:attr("cred_def_id")),"id":id};
      tx = subscription:established("Id",event:attr("sid"))[0]{"Tx"};
    }if(tx)then every{
      event:send({
          "eci": tx,
          "domain": "agent", "type": "cred_offer",
          "attrs": offer
        })
      send_directive("sent_offer", offer);
    }
    always{
      ent:sent_cred_offers := ent:sent_cred_offers.put(id,offer{"offer"})
    }
    
  }
  
  rule acceptCredentialOffer {
    select when agent cred_offer
      send_directive("sent_offer", event:attrs);
    always{
      ent:cred_offers := ent:cred_offers.put(event:attr("id"),event:attr("offer"))
    }
  }
  
  rule acceptCredentialOfferWithRequest {
    select when agent accept_credential_offer_with_request
    pre{
      id = random:uuid();
      id_credDef = credentialDefinition(event:attr("submitterDid"), event:attr("credDefId"));
      tx = subscription:established("Id",event:attr("sid"))[0]{"Tx"};
      request = {"id":id,"request":credentialRequest(event:attr("proverDid"),ent:cred_offers{event:attr("offerId")},id_credDef[1])}
    }if(tx)then every{
      event:send({
          "eci": tx,
          "domain": "agent", "type": "cred_request",
          "attrs": request
        })
      send_directive("sent_request", request);
    }
    always{
      ent:sent_cred_request := ent:sent_cred_request.put(id,request{"request"})
    }
  }
  
  rule acceptCredentialRequest {
    select when agent cred_request
      send_directive("sent_offer", event:attrs);
    always{
      ent:cred_requests := ent:cred_requests.put(event:attr("id"),event:attr("request"))
    }
  }
  
  rule issueCredentialFromRequest {
    select when agent issue_credential_from_request
    pre{
      id = random:uuid();
      tx = subscription:established("Id",event:attr("sid"))[0]{"Tx"};
      credential = {"id":id,"cred": createCredential(ent:cred_offers  {event:attr("offerId")},
                                                     ent:cred_requests{event:attr("requestId")}, 
                                                     event:attr("credAttributes"), //TODO, build raw and encoding object down the pipline
                                                     event:attr("revRegId"), 
                                                     event:attr("blobStorageReaderHandle"))}
    }if(tx)then every{
      event:send({
          "eci": tx,
          "domain": "agent", "type": "accept_cred",
          "attrs": credential
        })
      send_directive("sent_credential", credential);
    }
    always{
      ent:sent_cred := ent:sent_cred.put(id,credential{"cred"})
    }
  }
  
  rule acceptCredential {
    select when agent accept_cred
      send_directive("accepting_cred", event:attrs);
    always{
      ent:creds := ent:creds.put(event:attr("id"),event:attr("cred"))
    }
  }
  // proof request
  //
  rule nym {
    select when agent nym
    newNym(event:attr("signing_did"),
        event:attr("anchoring_did"),
        event:attr("anchoring_did_verkey"),
        event:attr("alias"),
        event:attr("role")
        )
  }
  rule sendNymRequest {
    select when agent send_nym_request
    pre{
      id = random:uuid()
      tx = subscription:established("Id",event:attr("sid"))[0]{"Tx"}
      request = {"id":id,
                 "tx":tx,
                 "anchoring_did"       :event:attr("anchoring_did"),
                 "anchoring_did_verkey":event:attr("anchoring_did_verkey"),
                 "alias"               :event:attr("alias"),
                 "role"                :event:attr("role")
      }
      
    }if(tx)then every{
      event:send({
          "eci": tx,
          "domain": "agent", "type": "nym_request",
          "attrs": request
        })
      send_directive("nym_requested", {"id":id,"request":request});
    }
    always{
      ent:sent_nym_requests := ent:sent_nym_requests.put(id,request)
    }
  }
  rule nymRequest {
    select when agent nym_request
    pre{
      id = event:attr("id").defaultsTo(random:uuid())
      ecdid = meta:eci
      request = {"id":id,
                 "did":ecdid,
                 "anchoring_did"       :event:attr("anchoring_did"),
                 "anchoring_did_verkey":event:attr("anchoring_did_verkey"),
                 "alias"               :event:attr("alias"),
                 "role"                :event:attr("role")
      }
    }
    send_directive("nym_requested", {"id":id,"request":request});
    always{
      ent:nym_requests := ent:nym_requests.put(id,request)
    }
  }

  rule acceptNymRequest {
    select when agent accept_nym_request
    pre{
      request = ent:nym_requests{event:attr("nym_request_id")}
    }
    if (request) then
        newNym(event:attr("signing_did").defaultsTo(getSigning_did()),//TODO: write getSigning_did
               request{"anchoring_did"},
               request{"anchoring_did_verkey"},
               request{"alias"},
               request{"role"}
        )
    fired{
      ent:nym_requests := ent:nym_requests.delete([event:attr("nym_request_id")]); // remove request
    }
  }
  rule linkSecret {// Todo, add directives.
    select when agent create_secret
    if(ent:secret_id.isnull())then
       createLinkSecret(null) setting(secretId)
    fired{ent:secret_id:= secretId}
  }
  rule connection {
    select when agent connect
      initiate_subscription(event:attr("destination_did"), event:attr("Rx_role"), event:attr("Tx_role") ) 
  }
  rule connectionAdded {
    select when wrangler subscription_added where event:attr("Tx_Rx_Type") == "Indy"
    send_directive("connectionAdded", event:attrs);
    always{
      ent:connections := ent:connections.put(event:attr("Id"),event:attrs)
    }
  }
  rule deleteWallet {
    select when pico intent_to_orphan or wrangler garbage_collection
    //if() then // should check to see if wallet exists.... but indy-sdk does not support this. 
      wallet_module:deleteWallet(id(),id(),null,null,null )
  }
  
}
