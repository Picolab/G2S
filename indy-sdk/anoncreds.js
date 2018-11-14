var sdk = require('indy-sdk');
const util = require('util');

sdk.setProtocolVersion(2);
sdk.setDefaultLogger("trace");
// code taken from http://www.danvk.org/hex2dec.html with Apache 2 license.
/**
 * A function for converting hex <-> dec w/o loss of precision.
 *
 * The problem is that parseInt("0x12345...") isn't precise enough to convert
 * 64-bit integers correctly.
 *
 * Internally, this uses arrays to encode decimal digits starting with the least
 * significant:
 * 8 = [8]
 * 16 = [6, 1]
 * 1024 = [4, 2, 0, 1]
 */

// Adds two arrays for the given base (10 or 16), returning the result.
// This turns out to be the only "primitive" operation we need.
function add(x, y, base) {
    var z = [];
    var n = Math.max(x.length, y.length);
    var carry = 0;
    var i = 0;
    while (i < n || carry) {
      var xi = i < x.length ? x[i] : 0;
      var yi = i < y.length ? y[i] : 0;
      var zi = carry + xi + yi;
      z.push(zi % base);
      carry = Math.floor(zi / base);
      i++;
    }
    return z;
  }
  
  // Returns a*x, where x is an array of decimal digits and a is an ordinary
  // JavaScript number. base is the number base of the array x.
  function multiplyByNumber(num, x, base) {
    if (num < 0) return null;
    if (num == 0) return [];
  
    var result = [];
    var power = x;
    while (true) {
      if (num & 1) {
        result = add(result, power, base);
      }
      num = num >> 1;
      if (num === 0) break;
      power = add(power, power, base);
    }
  
    return result;
  }
  
  function parseToDigitsArray(str, base) {
    var digits = str.split('');
    var ary = [];
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = parseInt(digits[i], base);
      if (isNaN(n)) return null;
      ary.push(n);
    }
    return ary;
  }
  
  function convertBase(str, fromBase, toBase) {
    var digits = parseToDigitsArray(str, fromBase);
    if (digits === null) return null;
  
    var outArray = [];
    var power = [1];
    for (var i = 0; i < digits.length; i++) {
      // invariant: at this point, fromBase^i = power
      if (digits[i]) {
        outArray = add(outArray, multiplyByNumber(digits[i], power, toBase), toBase);
      }
      power = multiplyByNumber(fromBase, power, toBase);
    }
  
    var out = '';
    for (var i = outArray.length - 1; i >= 0; i--) {
      out += outArray[i].toString(toBase);
    }
    return out;
  }
  
  function decToHex(decStr) {
    var hex = convertBase(decStr, 10, 16);
    return hex ? '0x' + hex : null;
  }
  
  function hexToDec(hexStr) {
    if (hexStr.substring(0, 2) === '0x') hexStr = hexStr.substring(2);
    hexStr = hexStr.toLowerCase();
    return convertBase(hexStr, 16, 10);
  }
  

module.exports = {
    issuerCreateSchema:{
        type:'function',
        args:['issuerDid','name','version','attrNames'],
        fn  :async function(args){
            return await sdk.issuerCreateSchema(args.issuerDid, args.name, args.version, args.attrNames );
        }
    },
    issuerCreateAndStoreCredentialDef:{
        type:'action',
        args:['wh', 'issuerDid', 'schema', 'tag', 'signatureType', 'config'],
        fn  :async function(args){
            console.log("args",args);
            return await sdk.issuerCreateAndStoreCredentialDef(parseInt(args.wh, 10), args.issuerDid, args.schema, args.tag, args.signatureType, args.config );
        }
    
    },
    issuerCreateAndStoreRevocReg:{
        type:'action',
        args:['wh', 'issuerDid', 'revocDefType', 'tag', 'credDefId', 'config', 'tailsWriterHandle'],
        fn  :async function(args){
            return await sdk.issuerCreateAndStoreRevocReg(parseInt(args.wh, 10), args.issuerDid, args.revocDefType, args.tag, args.credDefId, args.config, args.tailsWriterHandle );
        }
    },
    issuerCreateCredentialOffer:{
        type:'function',
        args:['wh', 'credDefId'],
        fn  :async function(args){
            return await sdk.issuerCreateCredentialOffer(parseInt(args.wh, 10), args.credDefId );
        }
    },
    decToHex:{
        type:'function',
        args:['decStr'],
        fn  :async function(args){
            return decToHex(args.decStr);
        }
    },
    hexToDec:{
        type:'function',
        args:['hexStr'],
        fn  :async function(args){
            return hexToDec(args.hexStr);
        }
    },
    issuerCreateCredential:{
        type:'function',
        args:['wh', 'credOffer', 'credReq', 'credValues', 'revRegId', 'blobStorageReaderHandle'],
        fn  :async function(args){
            console.log("args",args);
            return await sdk.issuerCreateCredential(parseInt(args.wh, 10), args.credOffer, args.credReq, args.credValues, args.revRegId, parseInt(args.blobStorageReaderHandle, 10) );
        }
    },
    issuerRevokeCredential:{
        type:'action',
        args:['wh', 'blobStorageReaderHandle', 'revRegId', 'credRevocId'],
        fn  :async function(args){
            return await sdk.issuerRevokeCredential(parseInt(args.wh, 10), args.blobStorageReaderHandle, args.revRegId, args.credRevocId );
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
            return await sdk.proverCreateMasterSecret(parseInt(args.wh, 10), args.masterSecretId );
        }
    },
    proverCreateCredentialReq:{
        type:'function',
        args:['wh', 'proverDid', 'credOffer', 'credDef', 'masterSecretId'],
        fn  :async function(args){
            return await sdk.proverCreateCredentialReq(parseInt(args.wh, 10), args.proverDid, args.credOffer, args.credDef, args.masterSecretId );
        }
    },
    proverStoreCredential:{
        type:'action',
        args:['wh', 'credId', 'credReqMetadata', 'cred', 'credDef', 'revRegDef'],
        fn  :async function(args){
            return await sdk.proverStoreCredential(parseInt(args.wh, 10), args.credId, args.credReqMetadata, args.cred, args.credDef, args.revRegDef );
        }
    },
    proverGetCredentials:{
        type:'function',
        args:['wh', 'filter'],
        fn  :async function(args){
            return await sdk.proverGetCredentials(parseInt(args.wh, 10), args.filter );
        }
    },
    proverGetCredential:{
        type:'function',
        args:['wh', 'credId'],
        fn  :async function(args){
            return await sdk.proverGetCredential(parseInt(args.wh, 10), args.credId );
        }
    },
    proverSearchCredsForProof:{
        type:'function',
        args:['wh','query'],
        fn  :async function(args){
            console.log(util.inspect(args, false, null, true /* enable colors */));
            let creds_to_get_from_ledger= {};
            let creds_for_proof = {};
            search_handle = await sdk.proverSearchCredentialsForProofReq(parseInt(args.wh, 10), args.query ,null );
            console.log("search handle",search_handle);
            for (key in args.query.requested_attributes) {
                console.log("key",key);
                credentials = await sdk.proverFetchCredentialsForProofReq(search_handle, 'attr1_referent' ,10);
                console.log(util.inspect(credentials, false, null, true /* enable colors */));
                /*creds_to_get_from_ledger[credentials[0].cred_info.referent] = credentials[0].cred_info;// this just takes the first credential found, there should be user input for this part.
                if (args.query.requested_attributes[key].hasOwnProperty("restrictions")){
                    creds_for_proof.requested_attributes[key] = {'cred_id': credentials[0].cred_info.referent, 'revealed': True};// again user input should be used here.
                }else{
                    creds_for_proof.self_attested_attributes[key] = args.query.requested_attributes.key[name];
                }*/
            }
            for (key in args.query.requested_predicates) {
                credentials = await sdk.proverFetchCredentialsForProofReq(search_handle,key,10);
                console.log(util.inspect(credentials, false, null, true /* enable colors */));
                //creds_to_get_from_ledger[credentials[0].cred_info.referent] = credentials[0].cred_info;
                //creds_for_proof.requested_predicates[key]={'cred_id': credentials[0].cred_info.referent};
            }
            //for (let index = 0; index < args.query.non_revoked.length; index++) { // TODO: support revocation 
            //}
            console.log(util.inspect(search_handle, false, null, true /* enable colors */));
            console.log(util.inspect(args.wh, false, null, true /* enable colors */));
            //await sdk.proverCloseCredentialsSearch(search_handle);
            console.log(util.inspect(search_handle, false, null, true /* enable colors */));
            console.log(util.inspect(args.wh, false, null, true /* enable colors */));
            console.log(util.inspect([creds_to_get_from_ledger,creds_for_proof], false, null, true /* enable colors */));
            return [creds_to_get_from_ledger,creds_for_proof];
        }

    },
    proverGetEntitiesFromLedger:{
        type:'function',
        args:['identifiers','poolHandle','schemaSubmitterDid','schemaId','credDefSubmitterDid','credDefId'],
        fn  :async function(args){
            console.log("args",args);
            let schemas = {};
            let credDefs = {};
            let revStates = {};
        
            for(let referent of Object.keys(identifiers)) {
                let item = identifiers[referent];
                //get schema
                let getSchemaRequest = await sdk.buildGetSchemaRequest( args.schemaSubmitterDid, args.schemaId);
                let getSchemaResponse = await sdk.submitRequest(parseInt(args.poolHandle,10), getSchemaRequest);
                let [, schema] = await sdk.parseGetSchemaResponse(getSchemaResponse);
                schemas[receivedSchema.id] = schema;
        
                //get credDef
                let getCredDefRequest = await sdk.buildGetCredDefRequest(args.credDefSubmitterDid, args.credDefId);
                let getCredDefResponse = await sdk.submitRequest(parseInt(args.poolHandle,10), getCredDefRequest);
                let [receivedCredDefId, receivedCredDef] = await sdk.parseGetCredDefResponse(getCredDefResponse);
                credDefs[receivedCredDefId] = receivedCredDef;
        
                //if (item.rev_reg_seq_no) {
                    // TODO Create Revocation States
                //}
            }
        
            return [schemas, credDefs, revStates];
        }
    },
    proverSearchCredentials:{
        type:'function',
        args:['wh', 'query'],
        fn  :async function(args){
            return await sdk.proverSearchCredentials(parseInt(args.wh, 10), args.query );
        }
    },
    proverFetchCredentials:{
        type:'function',
        args:['sh', 'count'],
        fn  :async function(args){
            return await sdk.proverFetchCredentials(parseInt(args.sh,10), args.count );
        }
    },
    proverCloseCredentialsSearch:{
        type:'action',
        args:['sh'],
        fn  :async function(args){
            return await sdk.proverCloseCredentialsSearch(parseInt(args.sh,10) );
        }
    },
    proverGetCredentialsForProofReq:{
        type:'function',
        args:['wh', 'proofRequest'],
        fn  :async function(args){
            return await sdk.proverGetCredentialsForProofReq(parseInt(args.wh, 10), args.proofRequest );
        }
    },
    proverSearchCredentialsForProofReq:{
        type:'function',
        args:['wh', 'proofRequest', 'extraQuery'],
        fn  :async function(args){
            return await sdk.proverSearchCredentialsForProofReq(parseInt(args.wh, 10), args.proofRequest, args.extraQuery );
        }
    },
    proverFetchCredentialsForProofReq:{
        type:'function',
        args:['sh', 'itemReferent', 'count'],
        fn  :async function(args){
            return await sdk.proverFetchCredentialsForProofReq(parseInt(args.sh,10), args.itemReferent, args.count );
        }
    },
    proverCloseCredentialsSearchForProofReq:{
        type:'function',
        args:['sh'],
        fn  :async function(args){
            return await sdk.proverCloseCredentialsSearchForProofReq(parseInt(args.sh,10) );
        }
    },
    proverCreateProof:{
        type:'action',
        args:['wh', 'proofReq', 'requestedCredentials', 'masterSecretName', 'schemas', 'credentialDefs', 'revStates'],
        fn  :async function(args){
            return await sdk.proverCreateProof(parseInt(args.wh, 10), args.proofReq, args.requestedCredentials, args.masterSecretName, args.schemas, args.credentialDefs, args.revStates );
        }
    },
    verifierGetEntitiesFromLedger:{
        type:'function',
        args:['identifiers'],
        fn  :async function(){
            let schemas = {};
            let credDefs = {};
            let revRegDefs = {};
            let revRegs = {};

            for(let referent of Object.keys(args.identifiers)) {
                let item = identifiers[referent];
                //let receivedSchema = //await indy.issuer.getSchema(item['schema_id']);
                schemas[receivedSchema.id] = receivedSchema;

                //let [receivedCredDefId, receivedCredDef] = //await indy.issuer.getCredDef(await indy.pool.get(), await indy.did.getEndpointDid(), item['cred_def_id']);
                credDefs[receivedCredDefId] = receivedCredDef;

                //if (item.rev_reg_seq_no) {
                    // TODO Get Revocation Definitions and Revocation Registries
                //}
            }
            return [schemas, credDefs, revRegDefs, revRegs];
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