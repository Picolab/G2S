var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let wallets= {};
module.exports = {
    isPairwiseExists:{
        type:'function',
        args:[ 'wh', 'theirDid'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createPaymentAddress(args.wh, args.theirDid);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    createPairwise:{
        type:'action',
        args:['wh', 'theirDid', 'myDid', 'metadata'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createPaymentAddress(args.wh, args.theirDid, args.myDid, args.metadata);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    }, 
    listPairwise:{
        type:'function',
        args:['wh'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createPaymentAddress(args.wh);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    getPairwise:{
        type:'function',
        args:['wh', 'theirDid'  ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createPaymentAddress(args.wh, args.theirDid);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    setPairwiseMetadata:{
        type:'action',
        args:['wh', 'theirDid', 'metadata' ],
        fn :async function(args,callback){
            let result;
            try {
                result = await sdk.createPaymentAddress(args.wh, args.theirDid, args.metadata);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    }
    
}