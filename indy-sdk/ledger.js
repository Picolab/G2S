var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    simpleNym:{
        type:'action',
        args:['poolHandle','signing_did','anchoring_did','anchoring_did_verkey','alias','role','walletHandle'],
        fn  :async function(args,callback){
            let nymRequest;
            try {
                nymRequest = await sdk.buildNymRequest(args.signing_did, args.anchoring_did, args.anchoring_did_verkey, args.alias, args.role);
                } 
            catch (e) {
                callback(e,nymRequest);
            }
            try {
                await sdk.signAndSubmitRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, args.nymRequest);
                } 
            catch (e) {
                callback(e,wallet);
            }
                callback(null,wallet);
            }    
    },
    signAndSubmitRequest:{
        type:'function',
        args:['poolHandle','signing_did','walletHandle','Request'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.signAndSubmitRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, args.Request);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    submitRequest:{
        type:'function',
        args:['poolHandle','Request'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.submitRequest( parseInt(args.poolHandle, 10),args.Request);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    submitAction:{
        type:'action',
        args:['poolHandle','request','nodes','timeout'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.submitAction( parseInt(args.poolHandle, 10), args.request, args.nodes, args.timeout);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    signRequest:{
        type:'function',
        args:['signing_did','walletHandle','Request'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.signRequest( parseInt(args.walletHandle, 10), args.signing_did, args.Request);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    multiSignRequest:{
        type:'function',
        args:['walletHandle','signingDid','request'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.multiSignRequest( parseInt(args.walletHandle, 10), args.signingDid, args.request);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetDdoRequest:{
        type:'function',
        args:['signingDid','targetDid'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetDdoRequest(args.signingDid, args.targetDid);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildNymRequest:{
        type:'function',
        args:['signingdid','anchoring_did','anchoring_did_verkey','alias','role'],
        fn  :async function(args,callback){
            let nymRequest;
            try {
                nymRequest = await sdk.buildNymRequest(args.signingdid, args.anchoring_did, args.anchoring_did_verkey, args.alias, args.role);
                } 
            catch (e) {
                callback(null,nymRequest);
            }
            callback(null,nymRequest);
            }    
    },
    /*buildAttribRequest:{
        type:'function',
        args:['submitterDid', 'targetDid', 'hash', 'raw', 'enc'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildAttribRequest(args.submitterDid, args.hash, args.raw, args.enc);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetAttribRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetAttribRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },*/
    buildGetNymRequest:{
        type:'function',
        args:['submitterDid','targetDid'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetNymRequest(args.submitterDid, args.targetDid);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },/*
    buildSchemaRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildSchemaRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetSchemaRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetSchemaRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetSchemaResponse:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetSchemaResponse( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildCredDefRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildCredDefRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetCredDefRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetCredDefRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetCredDefResponse:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetCredDefResponse( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildNodeRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildNodeRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetValidatorInfoRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetValidatorInfoRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetTxnRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetTxnRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPoolConfigRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPoolConfigRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPoolRestartRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPoolRestartRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPoolUpgradeRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPoolUpgradeRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildRevocRegDefRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildRevocRegDefRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetRevocRegDefRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetRevocRegDefRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetRevocRegDefResponse:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetRevocRegDefResponse( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildRevocRegEntryRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildRevocRegEntryRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetRevocRegRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetRevocRegRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetRevocRegDeltaRequest:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetRevocRegDeltaRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetRevocRegDeltaResponse:{
        type:'action',
        args:['poolHandle','signing_did','walletHandle','nymRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetRevocRegDeltaResponse( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, nymRequest);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    */
    }