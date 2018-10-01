var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    /*loadPlugin:{
        type:'action',
        args:['path'],
        fn  :async function(args){
            return await sdk.loadPlugin();
        }    
    },*/
    createPaymentAddress:{
        type:'action',
        args:['wh', 'paymentMethod', 'config'  ],
        fn  :async function(args){
            return await sdk.createPaymentAddress(args.wh, args.paymentMethod, args.config);
        }    
    },
    listPaymentAddresses:{
        type:'function',
        args:['wh' ],
        fn  :async function(args){
            return await sdk.listPaymentAddresses(args.wh);
        }    
    },
    addRequestFees:{
        type:'action',
        args:['wh', 'submitterDid', 'req', 'inputs', 'outputs', 'extra' ],
        fn  :async function(args){
            return await sdk.addRequestFees(args.wh, args.submitterDid, args.req, args.inputs, args.outputs, args.extra);
        }    
    },
    parseResponseWithFees:{
        type:'function',
        args:['paymentMethod','resp'],
        fn  :async function(args){
            return await sdk.parseResponseWithFees(args.paymentMethod, args.resp );
        }    
    },
    buildGetPaymentSourcesRequest:{
        type:'function',
        args:[  'wh', 'submitterDid', 'paymentAddress'],
        fn  :async function(args){
            return await sdk.buildGetPaymentSourcesRequest( args.wh, args.submitterDid, args.paymentAddress);
        }    
    },
    parseGetPaymentSourcesResponse:{
        type:'function',
        args:[ 'paymentMethod', 'resp'],
        fn  :async function(args){
            return await sdk.parseGetPaymentSourcesResponse(args.paymentMethod, args.resp);
        }    
    },
    buildPaymentReq:{
        type:'action',
        args:['wh', 'submitterDid', 'inputs', 'outputs', 'extra' ],
        fn  :async function(args){
            return await sdk.buildPaymentReq(args.wh, args.submitterDid, args.inputs, args.outputs, args.extra);
        }    
    },
    parsePaymentResponse:{
        type:'function',
        args:[ 'paymentMethod', 'resp'],
        fn  :async function(args){
            return await sdk.parsePaymentResponse(args.paymentMethod, args.resp);
        }    
    },
    buildMintReq:{
        type:'action',
        args:['wh', 'submitterDid', 'outputs', 'extra' ],
        fn  :async function(args){
            return await sdk.buildMintReq(args.wh, args.submitterDid, args.outputs, args.extra);
        }    
    },
    buildSetTxnFeesReq:{
        type:'action',
        args:[  'wh', 'submitterDid', 'paymentMethod', 'fees'],
        fn  :async function(args){
            return await sdk.buildSetTxnFeesReq( args.wh, args.submitterDid, args.paymentMethod, args.fees);
        }    
    },
    buildGetTxnFeesReq:{
        type:'function',
        args:[  'wh', 'submitterDid', 'paymentMethod' ],
        fn  :async function(args){
            return await sdk.buildGetTxnFeesReq( args.wh, args.submitterDid, args.paymentMethod );
        }    
    },
    parseGetTxnFeesResponse:{
        type:'function',
        args:[  'paymentMethod', 'resp'],
        fn  :async function(args){
            return await sdk.parseGetTxnFeesResponse( args.paymentMethod, args.resp);
        }    
    },
    buildVerifyPaymentReq:{
        type:'action',
        args:[ 'wh', 'submitterDid', 'receipt'],
        fn  :async function(args){
            return await sdk.buildVerifyPaymentReq(args.wh, args.submitterDid, args.receipt);
        }    
    },
    parseVerifyPaymentRespons:{
        type:'function',
        args:[ 'paymentMethod', 'resp' ],
        fn  :async function(args){
            return await sdk.parseVerifyPaymentRespons(args.paymentMethod, args.resp);
        }    
    }
}