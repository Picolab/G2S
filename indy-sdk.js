var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let pool;
let wallet;
module.exports = {
    /////////////////////////////////////////////////////////////////////////////////////////////
    /////////////   Pool
    /////////////////////////////////////////////////////////////////////////////////////////////
    createAndOpenPool: { type:'action',
                args:['poolName','poolConfig'],
                fn  :async function(args,callback){
                    try {
                        await sdk.deletePoolLedgerConfig(args.poolName);
                    } catch (e) {
                        if (e.message !== "...") {//TODO: get error code for ..
                            throw e;
                        }
                    } finally {
                        await sdk.createPoolLedgerConfig(args.poolName, args.poolConfig);
                        pool = await sdk.openPoolLedger(args.poolName);
                    }
                    callback(null,pool);
                },
            },
    openPool: { type:'action',
                args:['poolName'],
                fn  :async function(args,callback){
                    try {
                        pool = await sdk.openPoolLedger(args.poolName);
                    } catch (e) {
                        if (e.message !== "...") {//TODO: get error code for ..
                            throw e;
                        }
                    }
                    callback(null, pool);
                }
    },
    poolHandle:{type:'function',
                args:[],
                fn: async function(args,callback){
                    callback(null,pool);
                }
            },
    listPool: { type: 'function',
                args: [],
                fn: async function(args, callback){
                        callback(null, await sdk.listPools());
                    },
              },
    closePool:{ type: 'action',
                args: ['handle'],
                fn  : async function(args,callback){
                    let result;
                    try{
                        result = await sdk.closePoolLedger(args.handle);
                    } catch (e){
                        if (e.message !== "...") { //TODO: get error code for ..
                            throw e;
                        } 
                    } 
                    callback(null,result);
                    }  
                },
    /////////////////////////////////////////////////////////////////////////////////////////////
    /////////////   Wallet
    /////////////////////////////////////////////////////////////////////////////////////////////
    createAndOpenWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args,callback){
            try {
                await sdk.createWallet(
                    args.config,     //{id: args.walletName},
                    args.credentials //{key: args.password}
                );
            } catch (e) {
                if (e.message !== 'WalletAlreadyExistsError') {
                    console.warn('create wallet failed with message: ' + e.message);
                    throw e;
                }
            } finally {
                console.info('wallet already exists, try to open wallet');
            }
            wallet = await sdk.openWallet(
                {id: args.walletName},
                {key: args.userInformation.password}
            );
            callback(null,wallet);
        }
    },
    openWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args,callback){
            wallet = await sdk.openWallet(//could add optional arguments 
                args.config,     //{id: args.walletName},
                args.credentials //{key: args.password}
            );
            callback(null,wallet);
        }
    },
    walletHandle:{
        type:'function',
        args:[],
        fn: async function(args,callback){
            callback(null,wallet);
        }
    },
    closeWallet:{
        type:'action',
        args:['walletHandle'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.closeWallet(args.walletHandle);
            } catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('close wallet failed with message: ' + e.message);
                    throw e;
                }
            } 
            callback(null,result);
        }
    },
    createWallet:{
        type:'action',
        args:['walletName','password'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createWallet(
                    args.config,     //{id: args.walletName},
                    args.credentials //{key: args.password}
                );
            } catch (e) {
                if (e.message !== 'WalletAlreadyExistsError') {
                    console.warn('create wallet failed with message: ' + e.message);
                    throw e;
                }
            } 
            callback(null,result);
        }
    },
    deleteWallet:{
        type:'action',
        args:['walletHandle'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.closeWallet( // TODO: add optional arguments 
                    args.config,     //{id: args.walletName},
                    args.credentials //{key: args.password}
                );
            } catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('close wallet failed with message: ' + e.message);
                    throw e;
                }
            } 
            callback(null,result);
        }},
    //exportWallet
    //importWallet
    /////////////////////////////////////////////////////////////////////////////////////////////
    /////////////   Dids
    /////////////////////////////////////////////////////////////////////////////////////////////
    createAndStoreDid:{
        type:'action',
        args:['walletHandle','didInfo'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.ccreateAndStoreMyDid(args.walletHandle, args.didInfo);
            } catch (e) {
                if (e.message !== '...') { //TODO: look up error
                    console.warn(' failed with message: ' + e.message);
                    throw e;
                }
            } 
            callback(null,result);
        }
    },
    /////////////////////////////////////////////////////////////////////////////////////////////
    /////////////   Ledger
    /////////////////////////////////////////////////////////////////////////////////////////////
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
    },
    /////////////////////////////////////////////////////////////////////////////////////////////
    /////////////   Payment
    /////////////////////////////////////////////////////////////////////////////////////////////
    //loadPlugin:{},
    //transferTokens:{},
    //mintTokens:{},
    //setFees:{},
    //getFees:{}
    }