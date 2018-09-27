var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let pool;
module.exports = {
    createAndOpenPool: { type:'action',
                args:['poolName','poolConfig'],
                fn  :async function(args,callback){
                    try {
                        await sdk.deletePoolLedgerConfig(args.poolName);
                    } catch (e) {
                        if (e.message !== "...") {//TODO: get error code for ..
                            throw e;
                        }
                    } finally {
                        await sdk.createPoolLedgerConfig(args.poolName, args.poolConfig);
                        pool = await sdk.openPoolLedger(args.poolName);
                    }
                    callback(null,pool);
                },
            },
    openPool: { type:'action',
                args:['poolName'],
                fn  :async function(args,callback){
                    try {
                        pool = await sdk.openPoolLedger(args.poolName);
                    } catch (e) {
                        callback(e,pool);
                    }
                    callback(null, pool);
                }
    },
    poolHandle:{type:'function',
                args:[],
                fn: async function(args,callback){
                    callback(null,pool);
                }
            },
    listPool: { type: 'function',
                args: [],
                fn: async function(args, callback){
                    let result;
                    try{
                        result = await sdk.listPools();
                    } catch (e){
                        callback(e,result);
                    } 
                    callback(null,result);
                },
              },
    closePool:{ type: 'action',
                args: ['handle'],
                fn  : async function(args,callback){
                    let result;
                    try{
                        result = await sdk.closePoolLedger(args.handle);
                    } catch (e){
                        callback(e,result);
                    } 
                    callback(null,result);
                    }  
                },
    }