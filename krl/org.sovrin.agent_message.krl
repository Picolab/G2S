ruleset org.sovrin.agent_message {
  meta {
    use module io.picolabs.visual_params alias vp
    provides specToEventType,
      basicMsgMap,
      connInviteMap, connReqMap, connResMap,
      verify_signatures,
      trustPingMap, trustPingResMap
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

    // signature types
    t_sign_single = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/signature/1.0/ed25519Sha512_single"

    specToEventType = function(spec){
      p = spec.extract(re#^did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/([^/]+)/1.0/(.+)#);
      p => p.join("_") | null
    }
    basicMsgMap = function(content){
      {
        "@type": t_basic_msg,
        "~l10n": { "locale": "en" },
        "sent_time": time:now(),
        "content": content
      }
    }
    connInviteMap = function(id,label,key,endpoint){
      {
        "@type": t_conn_invit,
        //"@id": id || random:uuid(),
        "label": label || vp:dname(),
        "recipientKeys": [key],
        "serviceEndpoint": endpoint
      }
    }
    connReqMap = function(label, my_did, my_vk, endpoint){
      {
        "@id": random:uuid(),
        "@type": t_conn_req,
        "label": label || vp:dname(),
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
    toByteArray = function(str){
      1.range(8)
        .reduce(function(a,i){
          [a[0].append(a[1]%256),math:int(a[1]/256)]
        },[[]                   ,str.as("Number")  ])
        .head().reverse()
    }
    sign_field = function(my_did,my_vk,field){
      timestamp_bytes = toByteArray(time:now().time:strftime("%s"));
      sig_data_bytes = timestamp_bytes
        .append(field.encode().split("").map(function(x){ord(x)}));
      {
        "@type": t_sign_single,
        "signature": indy:crypto_sign(sig_data_bytes,my_did),
        "signer": my_vk,
        "sig_data": indy:sig_data(sig_data_bytes)
      }
    }
    connResMap = function(req_id, my_did, my_vk, endpoint){
      connection =
        {
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
              "serviceEndpoint": endpoint
             }]
          }
        };
      {
        "@type": t_conn_res,
        "@id": random:uuid(),
        "~thread": {"thid": req_id},
        "connection~sig": sign_field(my_did,my_vk,connection)
      }
    }
    verify_signed_field = function(signed_field){
      answer = indy:verify_signed_field(signed_field).klog("answer");
      timestamp = answer{"timestamp"}
        .values()
        .reduce(function(a,dig){a*256+dig});
      answer{"sig_verified"}
        => answer{"field"}.decode().put("timestamp",time:new(timestamp))
        | null
    }
    verify_signatures = function(map){
      map >< "connection~sig"
        => map.put("connection",verify_signed_field(map{"connection~sig"}))
         | map
    }
    trustPingMap = function(content){
      {
        "@type": t_ping_req,
        "@id": random:uuid()
      }
    }
    trustPingResMap = function(thid){
      {
        "@type": t_ping_res,
        "~thread": { "thid": thid }
      }
    }
  }
}
