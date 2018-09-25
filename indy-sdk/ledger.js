var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    simpleNym:{
        type:'action',
        args:['signing_did','anchoring_did','anchoring_did_verkey','alias','role','walletHandle'],// should pool handle be passed in?
        fn  :async function(args,callback){
            let nymRequest;
            try {
                nymRequest = await sdk.buildNymRequest(args.signing_did, args.anchoring_did, args.anchoring_did_verkey, args.alias, args.role);
                } 
            catch (e) {
                if (e.message !== '...') {// TODO: Look Up error
                    console.warn(' failed with message: ' + e.message);
                    throw e;
                }
            }
            try {
                await sdk.signAndSubmitRequest(pool, args.walletHandle, args.signing_did, nymRequest);
                } 
            catch (e) {
                if (e.message !== '...') {// TODO: Look Up error
                    console.warn(' failed with message: ' + e.message);
                    throw e;
                }
            }
                callback(null,wallet);
            }    
    }/*
    signAndSubmitRequest:
    submitRequest:
    submitAction:
    signRequest:
    multiSignRequest:
    buildGetDdoRequest:
    buildNymRequest:
    buildAttribRequest:
    buildGetAttribRequest:
    buildGetNymRequest:
    buildSchemaRequest:
    buildGetSchemaRequest:
    parseGetSchemaResponse:
    buildCredDefRequest:
    buildGetCredDefRequest:
    parseGetCredDefResponse:
    buildNodeRequest:
    buildGetValidatorInfoRequest:
    buildGetTxnRequest:
    buildPoolConfigRequest:
    buildPoolRestartRequest:
    buildPoolUpgradeRequest:
    buildRevocRegDefRequest:
    buildGetRevocRegDefRequest:
    parseGetRevocRegDefResponse:
    buildRevocRegEntryRequest:
    buildGetRevocRegRequest:
    buildGetRevocRegDeltaRequest:
    parseGetRevocRegDeltaResponse:
    */
    }