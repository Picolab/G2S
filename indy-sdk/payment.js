var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    /*loadPlugin:{
        type:'action',
        args:['path'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.loadPlugin();
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },*/
    createPaymentAddress:{
        type:'action',
        args:['wh', 'paymentMethod', 'config'  ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createPaymentAddress(args.wh, args.paymentMethod, args.config);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    listPaymentAddresses:{
        type:'function',
        args:['wh' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.listPaymentAddresses(args.wh);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    addRequestFees:{
        type:'action',
        args:['wh', 'submitterDid', 'req', 'inputs', 'outputs', 'extra' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.addRequestFees(args.wh, args.submitterDid, args.req, args.inputs, args.outputs, args.extra);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseResponseWithFees:{
        type:'function',
        args:['paymentMethod','resp'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseResponseWithFees(args.paymentMethod, args.resp );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetPaymentSourcesRequest:{
        type:'function',
        args:[  'wh', 'submitterDid', 'paymentAddress'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetPaymentSourcesRequest( args.wh, args.submitterDid, args.paymentAddress);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetPaymentSourcesResponse:{
        type:'function',
        args:[ 'paymentMethod', 'resp'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetPaymentSourcesResponse(args.paymentMethod, args.resp);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildPaymentReq:{
        type:'action',
        args:['wh', 'submitterDid', 'inputs', 'outputs', 'extra' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildPaymentReq(args.wh, args.submitterDid, args.inputs, args.outputs, args.extra);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parsePaymentResponse:{
        type:'function',
        args:[ 'paymentMethod', 'resp'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parsePaymentResponse(args.paymentMethod, args.resp);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildMintReq:{
        type:'action',
        args:['wh', 'submitterDid', 'outputs', 'extra' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildMintReq(args.wh, args.submitterDid, args.outputs, args.extra);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildSetTxnFeesReq:{
        type:'action',
        args:[  'wh', 'submitterDid', 'paymentMethod', 'fees'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildSetTxnFeesReq( args.wh, args.submitterDid, args.paymentMethod, args.fees);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildGetTxnFeesReq:{
        type:'function',
        args:[  'wh', 'submitterDid', 'paymentMethod' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildGetTxnFeesReq( args.wh, args.submitterDid, args.paymentMethod );
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseGetTxnFeesResponse:{
        type:'function',
        args:[  'paymentMethod', 'resp'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseGetTxnFeesResponse( args.paymentMethod, args.resp);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    buildVerifyPaymentReq:{
        type:'action',
        args:[ 'wh', 'submitterDid', 'receipt'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.buildVerifyPaymentReq(args.wh, args.submitterDid, args.receipt);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    },
    parseVerifyPaymentRespons:{
        type:'function',
        args:[ 'paymentMethod', 'resp' ],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.parseVerifyPaymentRespons(args.paymentMethod, args.resp);
                } 
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }    
    }
}