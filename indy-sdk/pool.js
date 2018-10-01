var sdk = require('indy-sdk')
sdk.setProtocolVersion(2);
let pool;
module.exports = {
    createAndOpenPool: { type:'action',
                args:['poolName','poolConfig'],
                fn  :async function(args){
                    try {
                        await sdk.deletePoolLedgerConfig(args.poolName);
                    } catch (e) {
                        if (e.message !== "...") {//TODO: get error code for ..
                            throw e;
                        }
                    } finally {
                        await sdk.createPoolLedgerConfig(args.poolName, args.poolConfig);
                        return await sdk.openPoolLedger(args.poolName);
                    }
                },
            },
    openPool: { type:'action',
                args:['poolName'],
                fn  :async function(args){
                    return await sdk.openPoolLedger(args.poolName);
                }
    },
    poolHandle:{type:'function',
                args:[],
                fn: async function(args){
                    return pool;
                }
            },
    listPool: { type: 'function',
                args: [],
                fn: async function(args){
                    return await sdk.listPools();
                },
              },
    closePool:{ type: 'action',
                args: ['handle'],
                fn  : async function(args){
                        return await sdk.closePoolLedger(args.handle);
                    }  
                },
    }