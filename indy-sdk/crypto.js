var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let wallets= {};
module.exports = {
createKey :{
         type:'action',
         args:[ 'wh', 'key' ],
         fn  :async function(args){
             return await sdk.createKey( args.wh, args.key );
         }
     }, 
setKeyMetadata :{
         type:'action',
         args:[ 'wh', 'verkey', 'metadata' ],
         fn  :async function(args){
             return await sdk.setKeyMetadata( args.wh, args.verkey, args.metadata );
         }
     }, 
getKeyMetadata :{
         type:'function',
         args:[ 'wh', 'verkey' ],
         fn  :async function(args){
             return await sdk.getKeyMetadata( args.wh, args.verkey );
         }
     },
cryptoSign :{
         type:'action',
         args:[ 'wh', 'signerVk', 'messageRaw' ],
         fn  :async function(args){
             return await sdk.cryptoSign( args.wh, args.signerVk, args.messageRaw );
         }
     },
cryptoVerify :{
         type:'function',
         args:[ 'signerVk', 'messageRaw', 'signatureRaw' ],
         fn  :async function(args){
             return await sdk.cryptoVerify( args.signerVk, args.messageRaw, args.signatureRaw );
         }
     },
cryptoAuthCrypt :{
         type:'function',
         args:[ 'wh', 'senderVk', 'recipientVk', 'messageRaw' ],
         fn  :async function(args){
             return await sdk.cryptoAuthCrypt( args.wh, args.senderVk, args.recipientVk, args.messageRaw );
         }
     },
cryptoAuthDecrypt :{
         type:'function',
         args:[ 'wh', 'recipientVk', 'encryptedMsgRaw' ],
         fn  :async function(args){
             return await sdk.cryptoAuthDecrypt( args.wh, args.recipientVk, args.encryptedMsgRaw );
         }
     },
cryptoAnonCrypt :{
         type:'action',
         args:[ 'recipientVk', 'messageRaw' ],
         fn  :async function(args){
             return await sdk.cryptoAnonCrypt( args.recipientVk, args.messageRaw );
         }
     },
cryptoAnonDecrypt :{
         type:'function',
         args:[ 'wh', 'recipientVk', 'encryptedMsg' ],
         fn  :async function(args){
             return await sdk.cryptoAnonDecrypt( args.wh, args.recipientVk, args.encryptedMsg );
         }
     },
}