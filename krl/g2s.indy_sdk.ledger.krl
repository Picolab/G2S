ruleset G2S.indy_sdk.ledger {
  meta {
    shares __testing, getNym,anchorSchema,blocks
    provides getNym,anchorSchema,blocks
  }
  global {
    __testing = { "queries":
      [ { "name": "getNym","args":["poolHandle","submitterDid","targetDid"] },
        { "name": "blocks","args":["pool_handle","submitter_did", "ledger_type"] }
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
    blocks = function(pool_handle,submitter_did, ledger_type){
      ledger:transactions(pool_handle,submitter_did, ledger_type)
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
    
    anchorSchema = function(pool_handle,wallet_handle,submitter_did,issuerDid,name,version,attrNames){
      schema_id_schema = anoncred:issuerCreateSchema(issuerDid,name,version,attrNames); // returns [schema_id,schema]
      request = ledger:buildSchemaRequest(submitter_did,schema_id_schema[1]);
      ledger:signAndSubmitRequest(pool_handle,wallet_handle,submitter_did,request)
    }
    
    getSchema = function(pool_handle,submitter_did,schema_id){
      request = ledger:buildgetschemarequest(submitter_did,schema_id);
      reponse = ledger:submitRequest(pool_handle,request);
      ledger:parsegetschemaresponse(reponse)
    }
    getCredentialDefinition = function(submitter_did,data){
      request = ledger:buildCredDefRequest(submitter_did,data);
      response = ledger:submitRequest(request.decode()); // request needs to be a json object??...
      ledger:parseGetCredDefResponse(response)
    }
    anchorCredDef = defaction(pool_handle,wallet_handle, issuer_did,schema,tag, signature_type, cred_def_config){
      every{
      anoncred:issuer_create_and_store_credential_def( wallet_handle, issuer_did, schema, tag, signature_type, cred_def_config ) setting(credDefId_credDef)
      anoncred:buildCredDefRequest(issuer_did,credDefId_credDef[1]) setting(request)
      }
      returns ledger:signAndSubmitRequest(pool_handle,wallet_handle,issuer_did,request)// does this return the cred_id 
    }
    issuerCreateCredentialOffer = function(wallet_handle,cred_def_id){
      anoncred:issuerCreateCredentialOffer(wallet_handle,cred_def_id)
    } 
    proverCreateCredentialReq = function(){
      anoncred:proverCreateCredentialReq(wallet_handle ,prover_did,cred_offer,cred_def,secret_id)
    }
    createLinkedSecret = function(wallet_handle, link_secret_id){
      anoncred:proverCreateMasterSecret(wallet_handle, link_secret_id)
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
