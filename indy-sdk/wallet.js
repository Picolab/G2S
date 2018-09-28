var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let wallets= {};
module.exports = {
    createAndOpenWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args,callback){
            try {
                await sdk.createWallet( args.config, args.credentials );
            } catch (e) {
                callback(e,result);
            }
            wallets[args.config.id] = await sdk.openWallet(
                    args.config,
                    args.credentials
            );
            callback(null,wallets[args.config.id]);
        }
    },
    openWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args,callback){            
            try {
                wallets[args.config.id] = await sdk.openWallet(
                    args.config,    
                    args.credentials
                );
            } catch (e) {
                callback(e,result);
        } 
        callback(null,wallets[args.config.id]);
        }
    },
    walletHandles:{
        type:'function',
        args:[],
        fn: async function(args,callback){
            callback(null,wallets);
        }
    },
    closeWallet:{
        type:'action',
        args:['walletHandle'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.closeWallet(parseInt(args.walletHandle, 10));
            } catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    createWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createWallet(
                    args.config, 
                    args.credentials
                );
            } catch (e) {
                callback(e,result);
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
                result = await sdk.closeWallet(
                    args.config,     
                    args.credentials
                );
            } catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }},
    exportWallet:{
        type:'function',
        args:['walletHandle','exportConfig'],
        fn: async function(args,callback){
            try {
                result = await sdk.exportWallet(
                    parseInt(args.walletHandle, 10),
                    args.exportConfig
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    importWallet:{
        type:'action',
        args:['config','credentials','importConfig'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.importWallet(
                    args.config, 
                    args.credentials,
                    args.importConfig
                );
            } catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    ///////////////////////////////DIDS//////////////////////////////////////
    createAndStoreMyDid:{
        type:'action',
        args:['walletHandle','didConfig'],
        fn  :async function(args,callback){
            let results;
            try {
                results = await sdk.createAndStoreMyDid (
                    parseInt(args.walletHandle, 10),
                    args.didConfig
                );
            } catch (e) {
                callback(e,result);
            }
            callback(null,results);
        }
    },
    replaceKeysStart:{
        type:'action',
        args:['walletHandle','did','identityConfig'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.replaceKeysStart (
                    parseInt(args.walletHandle, 10),
                    args.did,
                    args.identityConfig,
                );
            } catch (e) {
                callback(e,result);
            }
            callback(null,result);
        }
    },
    replaceKeysApply:{
        type:'action',
        args:['walletHandle','did'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createWreplaceKeysApply(
                    parseInt(args.walletHandle, 10),
                    args.did
                );
            } catch (e) {
                callback(e,result);
            }
            callback(null,result);
        }
    },
    storeTheirDid:{
        type:'action',
        args:['walletHandle','identityConfig'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.storeTheirDid (
                    parseInt(args.walletHandle, 10),
                    args.identityConfig
                );
            } catch (e) {
                callback(e,result);
            }
            callback(null,result);
        }
    },
    keyForDid:{
        type:'function',
        args:['poolHandle','walletHandle','did'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.keyForDid (
                    parseInt(args.poolHandle, 10),
                    parseInt(args.walletHandle, 10),
                    args.did
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    keyForLocalDid:{
        type:'function',
        args:['walletHandle','did'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.keyForLocalDid(
                    parseInt(args.walletHandle, 10),
                    args.exportConfig
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    setEndpointForDid:{
        type:'action',
        args:['walletHandle','did','adress','transportKey'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.setEndpointForDid(
                    parseInt(args.walletHandle, 10),
                    args.adress,
                    args.transportKey,
                    args.did
                );
            } catch (e) {
                callback(e,result);
            }
            callback(null,result);
        }
    },
    getEndpointForDid:{
        type:'function',
        args:['walletHandle','poolHandle'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.getEndpointForDid(
                    parseInt(args.walletHandle, 10),
                    parseInt(args.poolHandle, 10)
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    setDidMetadata:{
        type:'action',
        args:['walletHandle','did','metaData'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.setDidMetadata(
                    parseInt(args.walletHandle, 10),
                    args.did,
                    args.metaData
                );
            } catch (e) {
                callback(e,result);
            }
            callback(null,result);
        }
    },
    getDidMetadata:{
        type:'function',
        args:['walletHandle','did'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.getDidMetadata(
                    parseInt(args.walletHandle, 10),
                    args.did
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    getMyDidWithMeta:{
        type:'function',
        args:['walletHandle','did'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.getMyDidWithMeta(
                    parseInt(args.walletHandle, 10),
                    args.did
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    listMyDidsWithMeta:{
        type:'function',
        args:['walletHandle'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.listMyDidsWithMeta(
                    parseInt(args.walletHandle, 10)
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    },
    abbreviateVerkey:{
        type:'function',
        args:['did','fullVerkey'],
        fn: async function(args,callback){
            let result;
            try {
                result = await sdk.abbreviateVerkey(
                    args.did,
                    args.fullVerkey
                );
            }catch (e) {
                callback(e,result);
            } 
            callback(null,result);
        }
    }
    ///////////////////////////////Non-secret//////////////////////////////////////
    /*
    addWalletRecord ( wh, type, id, value, tags )
    updateWalletRecordValue ( wh, type, id, value ) 
    updateWalletRecordTags ( wh, type, id, tags ) 
    addWalletRecordTags ( wh, type, id, tags ) 
    deleteWalletRecordTags ( wh, type, id, tagNames )
    deleteWalletRecord ( wh, type, id ) 
    getWalletRecord ( wh, type, id, options ) 
    openWalletSearch ( wh, type, query, options )
    fetchWalletSearchNextRecords ( wh, walletSearchHandle, count ) 
    closeWalletSearch ( walletSearchHandle )
    */
    }