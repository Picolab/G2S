var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
module.exports = {
    issuerCreateSchema:{
        type:'action',
        args:['issuerDid','name','version','attrNames'],
        fn  :async function(args){
            return await sdk.issuerCreateSchema(args.issuerDid, args.name, args.version, args.attrNames );
        }
    },
    issuerCreateAndStoreCredentialDef:{
        type:'action',
        args:['wh', 'issuerDid', 'schema', 'tag', 'signatureType', 'config'],
        fn  :async function(args){
            return await sdk.issuerCreateAndStoreCredentialDef(args.wh, args.issuerDid, args.schema, args.tag, args.signatureType, args.config );
        }
    
    },
    issuerCreateAndStoreRevocReg:{
        type:'action',
        args:['wh', 'issuerDid', 'revocDefType', 'tag', 'credDefId', 'config', 'tailsWriterHandle'],
        fn  :async function(args){
            return await sdk.issuerCreateAndStoreRevocReg(args.wh, args.issuerDid, args.revocDefType, args.tag, args.credDefId, args.config, args.tailsWriterHandle );
        }
    },
    issuerCreateCredentialOffer:{
        type:'function',
        args:['wh', 'credDefId'],
        fn  :async function(args){
            return await sdk.issuerCreateCredentialOffer(args.wh, args.credDefId );
        }
    },
    issuerCreateCredential:{
        type:'action',
        args:['wh', 'args.credOffer', 'credReq', 'credValues', 'revRegId', 'blobStorageReaderHandle'],
        fn  :async function(args){
            return await sdk.issuerCreateCredential(args.wh, args.credOffer, args.credReq, args.credValues, args.revRegId, args.blobStorageReaderHandle );
        }
    },
    issuerRevokeCredential:{
        type:'action',
        args:['wh', 'blobStorageReaderHandle', 'revRegId', 'credRevocId'],
        fn  :async function(args){
            return await sdk.issuerRevokeCredential(args.wh, args.blobStorageReaderHandle, args.revRegId, args.credRevocId );
        }
    },
    issuerMergeRevocationRegistryDeltas:{
        type:'action',
        args:['revRegDelta', 'otherRevRegDelta'],
        fn  :async function(args){
            return await sdk.issuerMergeRevocationRegistryDeltas(args.revRegDelta, args.otherRevRegDelta );
        }
    },
    proverCreateMasterSecret:{
        type:'action',
        args:['wh', 'masterSecretId'],
        fn  :async function(args){
            return await sdk.proverCreateMasterSecret(args.wh, args.masterSecretId );
        }
    },
    proverCreateCredentialReq:{
        type:'function',
        args:['wh', 'proverDid', 'credOffer', 'credDef', 'masterSecretId'],
        fn  :async function(args){
            return await sdk.proverCreateCredentialReq(args.wh, args.proverDid, args.credOffer, args.credDef, args.masterSecretId );
        }
    },
    proverStoreCredential:{
        type:'action',
        args:['wh', 'credId', 'credReqMetadata', 'cred', 'credDef', 'revRegDef'],
        fn  :async function(args){
            return await sdk.proverStoreCredential(args.wh, args.credId, args.credReqMetadata, args.cred, args.credDef, args.revRegDef );
        }
    },
    proverGetCredentials:{
        type:'function',
        args:['wh', 'filter'],
        fn  :async function(args){
            return await sdk.proverGetCredentials(args.wh, args.filter );
        }
    },
    proverGetCredential:{
        type:'function',
        args:['wh', 'credId'],
        fn  :async function(args){
            return await sdk.proverGetCredential(args.wh, args.credId );
        }
    },
    proverSearchCredentials:{
        type:'function',
        args:['wh', 'query'],
        fn  :async function(args){
            return await sdk.proverSearchCredentials(args.wh, args.query );
        }
    },
    proverFetchCredentials:{
        type:'function',
        args:['sh', 'count'],
        fn  :async function(args){
            return await sdk.proverFetchCredentials(args.sh, args.count );
        }
    },
    proverCloseCredentialsSearch:{
        type:'action',
        args:['sh'],
        fn  :async function(args){
            return await sdk.proverCloseCredentialsSearch(args.sh );
        }
    },
    proverGetCredentialsForProofReq:{
        type:'function',
        args:['wh', 'proofRequest'],
        fn  :async function(args){
            return await sdk.proverGetCredentialsForProofReq(args.wh, args.proofRequest );
        }
    },
    proverSearchCredentialsForProofReq:{
        type:'function',
        args:['wh', 'proofRequest', 'extraQuery'],
        fn  :async function(args){
            return await sdk.proverSearchCredentialsForProofReq(args.wh, args.proofRequest, args.extraQuery );
        }
    },
    proverFetchCredentialsForProofReq:{
        type:'function',
        args:['sh', 'itemReferent', 'count'],
        fn  :async function(args){
            return await sdk.proverFetchCredentialsForProofReq(args.sh, args.itemReferent, args.count );
        }
    },
    proverCloseCredentialsSearchForProofReq:{
        type:'function',
        args:['sh'],
        fn  :async function(args){
            return await sdk.proverCloseCredentialsSearchForProofReq(args.sh );
        }
    },
    proverCreateProof:{
        type:'action',
        args:['wh', 'proofReq', 'requestedCredentials', 'masterSecretName', 'schemas', 'credentialDefs', 'revStates'],
        fn  :async function(args){
            return await sdk.proverCreateProof(args.wh, args.proofReq, args.requestedCredentials, args.masterSecretName, args.schemas, args.credentialDefs, args.revStates );
        }
    },
    verifierVerifyProof:{
        type:'function',
        args:['proofRequest', 'proof', 'schemas', 'credentialDefsJsons', 'revRegDefs', 'revRegs'],
        fn  :async function(args){
            return await sdk.verifierVerifyProof(args.proofRequest, args.proof, args.schemas, args.credentialDefsJsons, args.revRegDefs, args.revRegs );
        }
    },
    createRevocationState:{
        type:'action',
        args:['blobStorageReaderHandle', 'revRegDef', 'revRegDelta', 'timestamp', 'credRevId'],
        fn  :async function(args){
            return await sdk.createRevocationState(args.blobStorageReaderHandle, args.revRegDef, args.revRegDelta, args.timestamp, args.credRevId );
        }
    },
    updateRevocationState:{
        type:'action',
        args:['blobStorageReaderHandle', 'revState', 'revRegDef', 'revRegDelta', 'timestamp', 'credRevId'],
        fn  :async function(args){
            return await sdk.updateRevocationState(args.blobStorageReaderHandle, args.revState, args.revRegDef, args.revRegDelta, args.timestamp, args.credRevId );
        }
    },
}