var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let wallets= {};
module.exports = {
    isPairwiseExists:{
        type:'function',
        args:[ 'wh', 'theirDid'],
        fn  :async function(args){
            return await sdk.createPaymentAddress(args.wh, args.theirDid);
        }    
    },
    createPairwise:{
        type:'action',
        args:['wh', 'theirDid', 'myDid', 'metadata'],
        fn  :async function(args){
            return await sdk.createPaymentAddress(args.wh, args.theirDid, args.myDid, args.metadata);
        }    
    }, 
    listPairwise:{
        type:'function',
        args:['wh'],
        fn  :async function(args){
            return await sdk.createPaymentAddress(args.wh);
        }    
    },
    getPairwise:{
        type:'function',
        args:['wh', 'theirDid'  ],
        fn  :async function(args){
            return await sdk.createPaymentAddress(args.wh, args.theirDid);
        }    
    },
    setPairwiseMetadata:{
        type:'action',
        args:['wh', 'theirDid', 'metadata' ],
        fn :async function(args){
            return await sdk.createPaymentAddress(args.wh, args.theirDid, args.metadata);
        }    
    }
    
}