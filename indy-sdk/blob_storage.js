var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    openBlobStorageReader:{
        type:'function',
        args:['type', 'config'],
        fn  :async function(args){
            return await sdk.openBlobStorageReader( args.type, args.config);
        }
    },
    openBlobStorageWriter:{
        type:'action',
        args:['type', 'config'],
        fn  :async function(args){
            return await sdk.openBlobStorageWriter( args.type, args.config);
        }
    }
}
