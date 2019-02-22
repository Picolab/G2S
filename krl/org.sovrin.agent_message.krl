ruleset org.sovrin.agent_message {
  meta {
    provides specToEventType, invitationMap, connReqMap, connResMap
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    // message types

    t_basic_msg = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/basicmessage/1.0/message"

    t_conn_invit = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation"
    t_conn_req = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/request"
    t_conn_res = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/response"

    t_ping_req = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/trust_ping/1.0/ping"
    t_ping_res = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/trust_ping/1.0/ping_response"

    specToEventType = function(spec){
      p = spec.extract(re#^did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/([^/]+)/1.0/(.+)#);
      p => p.join("_") | null
    }
    invitationMap = function(id,label,key,endpoint){
      {
        "@type": t_conn_invit,
        "@id": id || random:uuid(),
        "label": label || random:word(),
        "recipientKeys": [key],
        "serviceEndpoint": endpoint
      }
    }
    connReqMap = function(label, my_did, my_vk, endpoint){
      {
        "@id": random:uuid(),
        "@type": t_conn_req,
        "label": label,
        "connection": {
          "DID": my_did,
          "DIDDoc": {
            "@context": "https://w3id.org/did/v1",
            "id": my_did,
            "publicKey": [{
              "id": my_did + "#keys-1",
              "type": "Ed25519VerificationKey2018",
              "controller": my_did,
              "publicKeyBase58": my_vk
            }],
            "service": [{
              "id": my_did + ";indy",
              "type": "IndyAgent",
              "recipientKeys": [my_vk],
              //"routingKeys": ["<example-agency-verkey>"],
              "serviceEndpoint": endpoint
            }]
          }
        }
      }
    }
    connResMap = function(req_id, my_did, my_vk, endpoint){
      {
        "@type": t_conn_res,
        "@id": random:uuid(),
        "~thread": {"thid": req_id},
        "connection": {
          "DID": my_did,
          "DIDDoc": {
            "@context": "https://w3id.org/did/v1",
            "id": my_did,
            "publicKey": [{
              "id": my_did + "#keys-1",
              "type": "Ed25519VerificationKey2018",
              "controller": my_did,
              "publicKeyBase58": my_vk
            }],
            "service": [{
              "id": my_did + ";indy",
              "type": "IndyAgent",
              "recipientKeys": [my_vk],
              //"routingKeys": ["<example-agency-verkey>"],
              "serviceEndpoint": endpoint
             }]
          }
        }
      }
    }
  }
}
