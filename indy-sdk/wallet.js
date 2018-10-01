var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let wallets= {};
module.exports = {
    createAndOpenWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args){
            await sdk.createWallet( args.config, args.credentials );
            wallets[args.config.id] = await sdk.openWallet( args.config, args.credentials);
            return wallets[args.config.id];
        }
    },
    openWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args){            
            wallets[args.config.id] = await sdk.openWallet(args.config,args.credentials);
            return wallets[args.config.id];
        }
    },
    walletHandles:{
        type:'function',
        args:[],
        fn: async function(args){
            return wallets;
        }
    },
    closeWallet:{
        type:'action',
        args:['walletHandle'],
        fn  :async function(args){
            return await sdk.closeWallet(parseInt(args.walletHandle, 10));
        }
    },
    createWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args){
            return await sdk.createWallet(args.config,args.credentials);
        }
    },
    deleteWallet:{
        type:'action',
        args:['config','credentials'],
        fn  :async function(args){
            return await sdk.deleteWallet( args.config,args.credentials );
        }
    },
    exportWallet:{
        type:'function',
        args:['walletHandle','exportConfig'],
        fn: async function(args){
            return await sdk.exportWallet( parseInt(args.walletHandle, 10), args.exportConfig );
        }
    },
    importWallet:{
        type:'action',
        args:['config','credentials','importConfig'],
        fn  :async function(args){
            return await sdk.importWallet( args.config,args.credentials,args.importConfig);
        }
    },
    ///////////////////////////////DIDS//////////////////////////////////////
    createAndStoreMyDid:{
        type:'action',
        args:['walletHandle','didConfig'],
        fn  :async function(args){
            return await sdk.createAndStoreMyDid(parseInt(args.walletHandle, 10),args.didConfig
            );
        }
    },
    replaceKeysStart:{
        type:'action',
        args:['walletHandle','did','identityConfig'],
        fn  :async function(args){
            return await sdk.replaceKeysStart ( parseInt(args.walletHandle, 10), args.did, args.identityConfig);
        }
    },
    replaceKeysApply:{
        type:'action',
        args:['walletHandle','did'],
        fn  :async function(args){
            return await sdk.createWreplaceKeysApply( parseInt(args.walletHandle, 10), args.did);
        }
    },
    storeTheirDid:{
        type:'action',
        args:['walletHandle','identityConfig'],
        fn  :async function(args){
            return await sdk.storeTheirDid( parseInt(args.walletHandle, 10), args.identityConfig);
        }
    },
    keyForDid:{
        type:'function',
        args:['poolHandle','walletHandle','did'],
        fn: async function(args){
            return await sdk.keyForDid( parseInt(args.poolHandle, 10), parseInt(args.walletHandle, 10), args.did);
        }
    },
    keyForLocalDid:{
        type:'function',
        args:['walletHandle','did'],
        fn: async function(args){
            return await sdk.keyForLocalDid( parseInt(args.walletHandle, 10), args.did);
        }
    },
    setEndpointForDid:{
        type:'action',
        args:['walletHandle','did','address','transportKey'],
        fn  :async function(args){
            return await sdk.setEndpointForDid( parseInt(args.walletHandle, 10), args.address, args.transportKey, args.did);
        }
    },
    getEndpointForDid:{
        type:'function',
        args:['walletHandle','poolHandle','did'],
        fn: async function(args){
            return await sdk.getEndpointForDid( parseInt(args.walletHandle, 10), parseInt(args.poolHandle, 10),args.did);
        }
    },
    setDidMetadata:{
        type:'action',
        args:['walletHandle','did','metaData'],
        fn  :async function(args){
            return await sdk.setDidMetadata( parseInt(args.walletHandle, 10), args.did, args.metaData);
        }
    },
    getDidMetadata:{
        type:'function',
        args:['walletHandle','did'],
        fn: async function(args){
            return await sdk.getDidMetadata( parseInt(args.walletHandle, 10), args.did);
        }
    },
    getMyDidWithMeta:{
        type:'function',
        args:['walletHandle','did'],
        fn: async function(args){
            return await sdk.getMyDidWithMeta( parseInt(args.walletHandle, 10), args.did);
        }
    },
    listMyDidsWithMeta:{
        type:'function',
        args:['walletHandle'],
        fn: async function(args){
            return await sdk.listMyDidsWithMeta( parseInt(args.walletHandle, 10));
        }
    },
    abbreviateVerkey:{
        type:'function',
        args:['did','fullVerkey'],
        fn: async function(args){
            return await sdk.abbreviateVerkey( args.did, args.fullVerkey);
        }
    },
    ///////////////////////////////Non-secret//////////////////////////////////////
    addWalletRecord :{
         type:'action',
         args:[ 'wh', 'type', 'id', 'value', 'tags' ],
         fn: async function(args){
             return await sdk.addWalletRecord(args.wh, args.type, args.id, args.value, args.tags );
         }
    },
    updateWalletRecordValue :{
         type:'action',
         args:[ 'wh', 'type', 'id', 'value' ],
         fn: async function(args){
             return await sdk.updateWalletRecordValue(args.wh, args.type, args.id, args.value );
         }
    },
    updateWalletRecordTags :{
         type:'action',
         args:[ 'wh', 'type', 'id', 'tags' ],
         fn: async function(args){
             return await sdk.updateWalletRecordTags(args.wh, args.type, args.id, args.tags );
         }
    },
 
    addWalletRecordTags :{
         type:'action',
         args:[ 'wh', 'type', 'id', 'tags' ],
         fn: async function(args){
             return await sdk.addWalletRecordTags(args.wh, args.type, args.id, args.tags );
         }
    },
 
    deleteWalletRecordTags :{
         type:'action',
         args:[ 'wh', 'type', 'id', 'tagNames' ],
         fn: async function(args){
             return await sdk.deleteWalletRecordTags(args.wh, args.type, args.id, args.tagNames );
         }
    },

    deleteWalletRecord :{
         type:'action',
         args:[ 'wh', 'type', 'id' ],
         fn: async function(args){
             return await sdk.deleteWalletRecord(args.wh, args.type, args.id );
         }
    },
 
    getWalletRecord :{
         type:'function',
         args:[ 'wh', 'type', 'id', 'options' ],
         fn: async function(args){
             return await sdk.getWalletRecord(args.wh, args.type, args.id, args.options );
         }
    },
 
    openWalletSearch :{
         type:'function',
         args:[ 'wh', 'type', 'query', 'options' ],
         fn: async function(args){
             return await sdk.openWalletSearch(args.wh, args.type, args.query, args.options );
         }
    },

    fetchWalletSearchNextRecords :{
         type:'function',
         args:[ 'wh', 'walletSearchHandle', 'count' ],
         fn: async function(args){
             return await sdk.fetchWalletSearchNextRecords(args.wh, args.walletSearchHandle,args.count );
         }
    },
 
    closeWalletSearch :{
         type:'function',
         args:[ 'walletSearchHandle' ],
         fn: async function(args){
             return await sdk.closeWalletSearch(args.walletSearchHandle );
         }
    },
    }