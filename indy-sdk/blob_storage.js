var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    openBlobStorageReader:{
    type:'function',
    args:['type', 'config'],
    fn  :async function(args,callback){
        let result;
        try {
            result = await sdk.openBlobStorageReader( args.type, args.config);
            } 
        catch (e) {
            callback(e,result);
        }
            callback(null,result);
        }
    },
openBlobStorageWriter:{
    type:'action',
    args:['type', 'config'],
    fn  :async function(args,callback){
        let result;
        try {
            result = await sdk.openBlobStorageWriter( args.type, args.config);
            } 
        catch (e) {
            callback(e,result);
        }
            callback(null,result);
        }
    }
}
