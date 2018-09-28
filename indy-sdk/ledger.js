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
    buildAttribRequest:{
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
        type:'function',
        args:['submitterDid', 'targetDid', 'hash', 'raw', 'enc' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetAttribRequest( args.submitterDid, args.targetDid, args.hash, args.raw, args.enc);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
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
    },
    buildSchemaRequest:{
        type:'action',
        args:[ 'submitterDid', 'data'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildSchemaRequest( args.submitterDid, args.data );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetSchemaRequest:{
        type:'function',
        args:['submitterDid', 'id' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetSchemaRequest(args.submitterDid, args.id);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetSchemaResponse:{
        type:'function',
        args:['getSchemaResponse'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetSchemaResponse( args.getSchemaResponse );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildCredDefRequest:{
        type:'action',
        args:['submitterDid','data'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildCredDefRequest( args.submitterDid, args.data );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetCredDefRequest:{
        type:'function',
        args:['submitterDid', 'id'  ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetCredDefRequest(args.submitterDid,args.id);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetCredDefResponse:{
        type:'function',
        args:['getCredDefResponse'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetCredDefResponse( args.getCredDefResponse );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildNodeRequest:{
        type:'action',
        args:[ 'submitterDid', 'targetDid', 'data' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildNodeRequest( args.submitterDid, args.targetDid, args.data  );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetValidatorInfoRequest:{
        type:'function',
        args:[ 'submitterDid' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetValidatorInfoRequest( args.submitterDid  );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetTxnRequest:{
        type:'function',
        args:[ 'submitterDid', 'ledgerType', 'data' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetTxnRequest(  args.submitterDid, args.ledgerType, args.data );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPoolConfigRequest:{
        type:'action',
        args:[ 'submitterDid', 'writes', 'force'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPoolConfigRequest( args.submitterDid, args.writes, args.force );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPoolRestartRequest:{
        type:'action',
        args:[ 'submitterDid', 'action', 'datetime'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPoolRestartRequest( args.submitterDid, args.action, args.datetime );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPoolUpgradeRequest:{
        type:'action',
        args:['submitterDid', 'name', 'version', 'action', 'sha256', 
              'timeout', 'schedule', 'justification', 'reinstall', 'force', 'package' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPoolUpgradeRequest( args.submitterDid, args.name, args.version, args.action, args.sha256, args.timeout, args.schedule, args.justification, args.reinstall, args.force, args.package );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildRevocRegDefRequest:{
        type:'action',
        args:['submitterDid', 'data'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildRevocRegDefRequest(args.submitterDid, args.data);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetRevocRegDefRequest:{
        type:'function',
        args:[ 'submitterDid', 'id'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetRevocRegDefRequest( args.submitterDid, args.id );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetRevocRegDefResponse:{
        type:'function',
        args:['getRevocRefDefResponse' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetRevocRegDefResponse( args.getRevocRefDefResponse );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildRevocRegEntryRequest:{
        type:'action',
        args:[  'submitterDid', 'revocRegDefId', 'revDefType', 'value' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildRevocRegEntryRequest(  args.submitterDid, args.revocRegDefId, args.revDefType, args.value );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetRevocRegRequest:{
        type:'function',
        args:[ 'submitterDid', 'revocRegDefId', 'timestamp' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetRevocRegRequest(  args.submitterDid, args.revocRegDefId, args.timestamp );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetRevocRegDeltaRequest:{
        type:'action',
        args:[ 'submitterDid', 'revocRegDefId', 'from', 'to' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetRevocRegDeltaRequest(  args.submitterDid, args.revocRegDefId, args.from, args.to );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetRevocRegDeltaResponse:{
        type:'action',
        args:['getRevocRegDeltaResponse'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetRevocRegDeltaResponse( args.getRevocRegDeltaResponse );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    }