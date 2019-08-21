ruleset org.sovrin.agent_message {
  meta {
    provides
      localServiceEndpoint,
      specToEventType,
      basicMsgMap,
      connInviteMap, connReqMap, connResMap,
      verify_signatures,
      trustPingMap, trustPingResMap,
      routeFwdMap, packMsg
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
    // local service endpoint
    localServiceEndpoint = function(eci,eid){
      <<#{meta:host}/sky/event/#{eci}/#{eid}/sovrin/new_message>>
    }

    // message types

    t_route_fwd = "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/routing/1.0/forward"

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
    connInviteMap = function(id,label,key,endpoint,routingKeys){
      minimal = {
        "@type": t_conn_invit,
        //"@id": id || random:uuid(),
        "label": label,
        "recipientKeys": [key],
        "serviceEndpoint": endpoint
      };
      routingKeys.isnull() => minimal |
        minimal.put({"routingKeys": routingKeys})
    }
    connMap = function(my_did, my_vk, endpoint,routingKeys){
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
              "routingKeys": routingKeys.defaultsTo([]),
              "serviceEndpoint": endpoint
            }]
          }
      }
    }
    connReqMap = function(label, my_did, my_vk, endpoint, routingKeys){
      {
        "@id": random:uuid(),
        "@type": t_conn_req,
        "label": label,
        "connection": connMap(my_did, my_vk, endpoint, routingKeys)
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
    connResMap = function(req_id, my_did, my_vk, endpoint, routingKeys){
      connection = connMap(my_did, my_vk, endpoint, routingKeys);
      {
        "@type": t_conn_res,
        "@id": random:uuid(),
        "~thread": {"thid": req_id},
        "connection~sig": sign_field(my_did,my_vk,connection)
      }
    }
    verify_signed_field = function(signed_field){
      signature = signed_field{"signature"};
      _signed_field = signature.match(re#==$#) => signed_field
        | signed_field.put("signature",signature + "==");
      answer = indy:verify_signed_field(_signed_field);
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
    routeFwdMap = function(to,pm){
      {
        "@type": t_route_fwd,
        "to": to,
        "msg": pm
      }
    }
    packMsg = function(conn,msg,outer_did){
      their_vk = conn{"their_vk"};
      this_did = outer_did.defaultsTo(conn{"my_did"});
      conn{"their_routing"}.defaultsTo([]).reduce(
        function(a,rk){
          fm = routeFwdMap(a[1],a.head());
          [indy:pack(fm.encode(),[rk],this_did),rk]
        },
        [indy:pack(msg.encode(),[their_vk],this_did),their_vk]
      ).head()
    }
  }
}
