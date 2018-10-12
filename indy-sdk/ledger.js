var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
last_transaction = 0;
transactions=[];
module.exports = {
    transactions:{
        type:'function',
        args:['poolHandle','submitterDid', 'ledgerType'],
        fn  :async function(args){
            let error = '', results=[] ;
            while (true) {
                try {
                    request = sdk.buildGetTxnRequest ( submitterDid, ledgerType, last_transaction )
                    results.append(sdk.submitRequest(poolHandle,request));
                    last_transaction ++;
                } catch (error) {
                    console.log(error);
                    last_transaction = 0;
                    return results;  
                } 
            }
        }    
    },
    simpleNym:{
        type:'action',
        args:['poolHandle','signing_did','anchoring_did','anchoring_did_verkey','alias','role','walletHandle'],
        fn  :async function(args){
            nymRequest = await sdk.buildNymRequest(args.signing_did, args.anchoring_did, args.anchoring_did_verkey, args.alias, args.role);
            return await sdk.signAndSubmitRequest( parseInt(args.poolHandle, 10),  parseInt(args.walletHandle, 10), args.signing_did, args.nymRequest);
        }    
    },
    signAndSubmitRequest:{
        type:'function',
        args:['poolHandle','walletHandle','signing_did','Request'],
        fn  :async function(args){
            return await sdk.signAndSubmitRequest( parseInt(args.poolHandle, 10),parseInt(args.walletHandle, 10), args.signing_did , args.Request);
        }    
    },
    submitRequest:{
        type:'function',
        args:['poolHandle','Request'],
        fn  :async function(args){
            return await sdk.submitRequest( parseInt(args.poolHandle, 10),args.Request);
        }    
    },
    submitAction:{
        type:'action',
        args:['poolHandle','request','nodes','timeout'],
        fn  :async function(args){
            return await sdk.submitAction( parseInt(args.poolHandle, 10), args.request, args.nodes, args.timeout);
        }    
    },
    signRequest:{
        type:'function',
        args:['signing_did','walletHandle','Request'],
        fn  :async function(args){
            return await sdk.signRequest( parseInt(args.walletHandle, 10), args.signing_did, args.Request);
        }    
    },
    multiSignRequest:{
        type:'function',
        args:['walletHandle','signingDid','request'],
        fn  :async function(args){
            return await sdk.multiSignRequest( parseInt(args.walletHandle, 10), args.signingDid, args.request);
        }    
    },
    buildGetDdoRequest:{
        type:'function',
        args:['signingDid','targetDid'],
        fn  :async function(args){
            return await sdk.buildGetDdoRequest(args.signingDid, args.targetDid);
        }    
    },
    buildNymRequest:{
        type:'function',
        args:['signingdid','anchoring_did','anchoring_did_verkey','alias','role'],
        fn  :async function(args){
                console.log("args",args);
                return await sdk.buildNymRequest(args.signingdid, args.anchoring_did, args.anchoring_did_verkey, args.alias, args.role);
            }    
    },
    buildAttribRequest:{
        type:'function',
        args:['submitterDid', 'targetDid', 'hash', 'raw', 'enc'],
        fn  :async function(args){
            return await sdk.buildAttribRequest(args.submitterDid, args.hash, args.raw, args.enc);
        }    
    },
    buildGetAttribRequest:{
        type:'function',
        args:['submitterDid', 'targetDid', 'hash', 'raw', 'enc' ],
        fn  :async function(args){
            return await sdk.buildGetAttribRequest( args.submitterDid, args.targetDid, args.hash, args.raw, args.enc);
        }    
    },
    buildGetNymRequest:{
        type:'function',
        args:['submitterDid','targetDid'],
        fn  :async function(args){
            return await sdk.buildGetNymRequest(args.submitterDid, args.targetDid);
        }    
    },
    buildSchemaRequest:{
        type:'function',
        args:[ 'submitterDid', 'data'],
        fn  :async function(args){
            return await sdk.buildSchemaRequest( args.submitterDid, args.data );
        }    
    },
    buildGetSchemaRequest:{
        type:'function',
        args:['submitterDid', 'id' ],
        fn  :async function(args){
            console.log('args',args);
            return await sdk.buildGetSchemaRequest(args.submitterDid, args.id);
        }    
    },
    parseGetSchemaResponse:{
        type:'function',
        args:['getSchemaResponse'],
        fn  :async function(args){
            return await sdk.parseGetSchemaResponse( args.getSchemaResponse );
        }    
    },
    buildCredDefRequest:{
        type:'function',
        args:['submitterDid','data'],
        fn  :async function(args){
            return await sdk.buildCredDefRequest( args.submitterDid, args.data );
        }    
    },
    buildGetCredDefRequest:{
        type:'function',
        args:['submitterDid', 'id'  ],
        fn  :async function(args){
            return await sdk.buildGetCredDefRequest(args.submitterDid,args.id);
        }    
    },
    parseGetCredDefResponse:{
        type:'function',
        args:['getCredDefResponse'],
        fn  :async function(args){
            return await sdk.parseGetCredDefResponse( args.getCredDefResponse );
        }    
    },
    buildNodeRequest:{
        type:'action',
        args:[ 'submitterDid', 'targetDid', 'data' ],
        fn  :async function(args){
            return await sdk.buildNodeRequest( args.submitterDid, args.targetDid, args.data  );
        }    
    },
    buildGetValidatorInfoRequest:{
        type:'function',
        args:[ 'submitterDid' ],
        fn  :async function(args){
            return await sdk.buildGetValidatorInfoRequest( args.submitterDid  );
        }    
    },
    buildGetTxnRequest:{
        type:'function',
        args:[ 'submitterDid', 'ledgerType', 'data' ],
        fn  :async function(args){
            return await sdk.buildGetTxnRequest(  args.submitterDid, args.ledgerType, args.data );
        }    
    },
    buildPoolConfigRequest:{
        type:'action',
        args:[ 'submitterDid', 'writes', 'force'],
        fn  :async function(args){
            return await sdk.buildPoolConfigRequest( args.submitterDid, args.writes, args.force );
        }    
    },
    buildPoolRestartRequest:{
        type:'action',
        args:[ 'submitterDid', 'action', 'datetime'],
        fn  :async function(args){
            return await sdk.buildPoolRestartRequest( args.submitterDid, args.action, args.datetime );
        }    
    },
    buildPoolUpgradeRequest:{
        type:'action',
        args:['submitterDid', 'name', 'version', 'action', 'sha256', 
              'timeout', 'schedule', 'justification', 'reinstall', 'force', 'package' ],
        fn  :async function(args){
            return await sdk.buildPoolUpgradeRequest( args.submitterDid, args.name, args.version, args.action, args.sha256, args.timeout, args.schedule, args.justification, args.reinstall, args.force, args.package );
        }    
    },
    buildRevocRegDefRequest:{
        type:'action',
        args:['submitterDid', 'data'],
        fn  :async function(args){
            return await sdk.buildRevocRegDefRequest(args.submitterDid, args.data);
        }    
    },
    buildGetRevocRegDefRequest:{
        type:'function',
        args:[ 'submitterDid', 'id'],
        fn  :async function(args){
            return await sdk.buildGetRevocRegDefRequest( args.submitterDid, args.id );
        }    
    },
    parseGetRevocRegDefResponse:{
        type:'function',
        args:['getRevocRefDefResponse' ],
        fn  :async function(args){
            return await sdk.parseGetRevocRegDefResponse( args.getRevocRefDefResponse );
        }    
    },
    buildRevocRegEntryRequest:{
        type:'action',
        args:[  'submitterDid', 'revocRegDefId', 'revDefType', 'value' ],
        fn  :async function(args){
            return await sdk.buildRevocRegEntryRequest(  args.submitterDid, args.revocRegDefId, args.revDefType, args.value );
        }    
    },
    buildGetRevocRegRequest:{
        type:'function',
        args:[ 'submitterDid', 'revocRegDefId', 'timestamp' ],
        fn  :async function(args){
            return await sdk.buildGetRevocRegRequest(  args.submitterDid, args.revocRegDefId, args.timestamp );
        }    
    },
    buildGetRevocRegDeltaRequest:{
        type:'action',
        args:[ 'submitterDid', 'revocRegDefId', 'from', 'to' ],
        fn  :async function(args){
            return await sdk.buildGetRevocRegDeltaRequest(  args.submitterDid, args.revocRegDefId, args.from, args.to );
        }    
    },
    parseGetRevocRegDeltaResponse:{
        type:'action',
        args:['getRevocRegDeltaResponse'],
        fn  :async function(args){
            return await sdk.parseGetRevocRegDeltaResponse( args.getRevocRegDeltaResponse );
        }    
    },
    }