var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let wallets= {};
module.exports = {
    createAndOpenWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args,callback){
            try {
                await sdk.createWallet(
                    args.config,
                    args.credentials
                );
            } catch (e) {
                if (e.message !== 'WalletAlreadyExistsError') {
                    console.warn('create wallet failed with message: ' + e.message);
                    throw e;
                }
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
                if (e.message !== '...') {// TODO: get error....
                    console.warn('open wallet failed with message: ' + e.message);
                    throw e;
                }
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
                    args.config, 
                    args.credentials
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
                result = await sdk.closeWallet(
                    args.config,     
                    args.credentials
                );
            } catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('close wallet failed with message: ' + e.message);
                    throw e;
                }
            } 
            callback(null,result);
        }},
    exportWallet:{
        type:'function',
        args:['walletHandle','exportConfig'],
        fn: async function(args,callback){
            try {
                result = await sdk.exportWallet(
                    args.walletHandle,
                    args.exportConfig
                );
            }catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('export wallet failed with message: ' + e.message);
                    throw e;
                }
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
                if (e.message !== '....') { //TODO: get error code
                    console.warn('import wallet failed with message: ' + e.message);
                    throw e;
                }
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
                if (e.message !== '...') { //TODO : get code
                    console.warn('create did failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.did,
                    args.identityConfig,
                );
            } catch (e) {
                if (e.message !== '...') { // TODO: get error code
                    console.warn('replaceKeyStart failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.did
                );
            } catch (e) {
                if (e.message !== '...') { // TODO: get error code
                    console.warn('replaceKeysApply failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.identityConfig
                );
            } catch (e) {
                if (e.message !== '...') { // get error code
                    console.warn('storeTheirDid failed with message: ' + e.message);
                    throw e;
                }
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
                    args.poolHandle,
                    args.walletHandle,
                    args.did
                );
            }catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('keyForDid failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.exportConfig
                );
            }catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('keyForLocalDid failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.adress,
                    args.transportKey,
                    args.did
                );
            } catch (e) {
                if (e.message !== 'WalletAlreadyExistsError') {
                    console.warn('setEndpointForDid failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.poolHandle
                );
            }catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('getEndpointForDid failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.did,
                    args.metaData
                );
            } catch (e) {
                if (e.message !== 'WalletAlreadyExistsError') {
                    console.warn('setDidMetadata failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle,
                    args.did
                );
            }catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('getDidMetadata failed with message: ' + e.message);
                    throw e;
                }
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
                if (e.message !== '...') {// TODO: get error....
                    console.warn('getMyDidWithMeta failed with message: ' + e.message);
                    throw e;
                }
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
                    args.walletHandle
                );
            }catch (e) {
                if (e.message !== '...') {// TODO: get error....
                    console.warn('listMyDidsWithMeta failed with message: ' + e.message);
                    throw e;
                }
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
                if (e.message !== '...') {// TODO: get error....
                    console.warn('abbreviateVerkey failed with message: ' + e.message);
                    throw e;
                }
            } 
            callback(null,result);
        }
    }
    }