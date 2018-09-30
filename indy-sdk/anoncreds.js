var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    issuerCreateSchema:{
        type:'action',
        args:['issuerDid','name','version','attrNames'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerCreateSchema(args.issuerDid, args.name, args.version, args.attrNames );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
        }
    },

    issuerCreateAndStoreCredentialDef:{
        type:'action',
        args:['wh', 'issuerDid', 'schema', 'tag', 'signatureType', 'config'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerCreateAndStoreCredentialDef(args.wh, args.issuerDid, args.schema, args.tag, args.signatureType, args.config );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    issuerCreateAndStoreRevocReg:{
        type:'action',
        args:['wh', 'issuerDid', 'revocDefType', 'tag', 'credDefId', 'config', 'tailsWriterHandle'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerCreateAndStoreRevocReg(args.wh, args.issuerDid, args.revocDefType, args.tag, args.credDefId, args.config, args.tailsWriterHandle );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    issuerCreateCredentialOffer:{
        type:'function',
        args:['wh', 'credDefId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerCreateCredentialOffer(args.wh, args.credDefId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    issuerCreateCredential:{
        type:'action',
        args:['wh', 'args.credOffer', 'credReq', 'credValues', 'revRegId', 'blobStorageReaderHandle'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerCreateCredential(args.wh, args.credOffer, args.credReq, args.credValues, args.revRegId, args.blobStorageReaderHandle );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    issuerRevokeCredential:{
        type:'action',
        args:['wh', 'blobStorageReaderHandle', 'revRegId', 'credRevocId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerRevokeCredential(args.wh, args.blobStorageReaderHandle, args.revRegId, args.credRevocId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    issuerMergeRevocationRegistryDeltas:{
        type:'action',
        args:['revRegDelta', 'otherRevRegDelta'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.issuerMergeRevocationRegistryDeltas(args.revRegDelta, args.otherRevRegDelta );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverCreateMasterSecret:{
        type:'action',
        args:['wh', 'masterSecretId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverCreateMasterSecret(args.wh, args.masterSecretId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverCreateCredentialReq:{
        type:'function',
        args:['wh', 'proverDid', 'credOffer', 'credDef', 'masterSecretId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverCreateCredentialReq(args.wh, args.proverDid, args.credOffer, args.credDef, args.masterSecretId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverStoreCredential:{
        type:'action',
        args:['wh', 'credId', 'credReqMetadata', 'cred', 'credDef', 'revRegDef'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverStoreCredential(args.wh, args.credId, args.credReqMetadata, args.cred, args.credDef, args.revRegDef );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverGetCredentials:{
        type:'function',
        args:['wh', 'filter'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverGetCredentials(args.wh, args.filter );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverGetCredential:{
        type:'function',
        args:['wh', 'credId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverGetCredential(args.wh, args.credId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverSearchCredentials:{
        type:'function',
        args:['wh', 'query'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverSearchCredentials(args.wh, args.query );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverFetchCredentials:{
        type:'function',
        args:['sh', 'count'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverFetchCredentials(args.sh, args.count );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverCloseCredentialsSearch:{
        type:'action',
        args:['sh'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverCloseCredentialsSearch(args.sh );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverGetCredentialsForProofReq:{
        type:'function',
        args:['wh', 'proofRequest'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverGetCredentialsForProofReq(args.wh, args.proofRequest );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverSearchCredentialsForProofReq:{
        type:'function',
        args:['wh', 'proofRequest', 'extraQuery'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverSearchCredentialsForProofReq(args.wh, args.proofRequest, args.extraQuery );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverFetchCredentialsForProofReq:{
        type:'function',
        args:['sh', 'itemReferent', 'count'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverFetchCredentialsForProofReq(args.sh, args.itemReferent, args.count );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverCloseCredentialsSearchForProofReq:{
        type:'function',
        args:['sh'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverCloseCredentialsSearchForProofReq(args.sh );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    proverCreateProof:{
        type:'action',
        args:['wh', 'proofReq', 'requestedCredentials', 'masterSecretName', 'schemas', 'credentialDefs', 'revStates'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.proverCreateProof(args.wh, args.proofReq, args.requestedCredentials, args.masterSecretName, args.schemas, args.credentialDefs, args.revStates );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    verifierVerifyProof:{
        type:'function',
        args:['proofRequest', 'proof', 'schemas', 'credentialDefsJsons', 'revRegDefs', 'revRegs'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.verifierVerifyProof(args.proofRequest, args.proof, args.schemas, args.credentialDefsJsons, args.revRegDefs, args.revRegs );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },

    createRevocationState:{
        type:'action',
        args:['blobStorageReaderHandle', 'revRegDef', 'revRegDelta', 'timestamp', 'credRevId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.createRevocationState(args.blobStorageReaderHandle, args.revRegDef, args.revRegDelta, args.timestamp, args.credRevId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
        }
    },

    updateRevocationState:{
        type:'action',
        args:['blobStorageReaderHandle', 'revState', 'revRegDef', 'revRegDelta', 'timestamp', 'credRevId'],
        fn  :async function(args,callback){
            let result;
            try {
                result = await sdk.updateRevocationState(args.blobStorageReaderHandle, args.revState, args.revRegDef, args.revRegDelta, args.timestamp, args.credRevId );
                }
            catch (e) {
                callback(e,result);
            }
                callback(null,result);
            }
    },
}