ruleset org.sovrin.agent {
  meta {
    use module org.sovrin.agent_message alias a_msg
    use module io.picolabs.wrangler alias wrangler
    shares __testing, agent_Rx
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "agent_Rx" }
      // , { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "sovrin", "type": "need_invitation", "attrs": [ "auto_accept" ] }
      , { "domain": "sovrin", "type": "new_invitation", "attrs": [ "url" ] }
      ]
    }
    agent_Rx = function(){
      wrangler:channel("agent")
    }
    sEp = function(eci,eid,e_d,e_t){
      d = e_d || "sovrin";
      t = e_t || "new_message";
      <<#{meta:host}/sky/event/#{eci}/#{eid}/#{d}/#{t}>>
    }
    invitation = function(){
      uKR = agent_Rx();
      eci = uKR{"id"};
      im = a_msg:connInviteMap(
        ent:label,
        null, // @id
        uKR{["sovrin","indyPublic"]},
        sEp(eci)
      );
      ep = <<#{meta:host}/sky/cloud/#{eci}/org.sovrin.agent.ui/html.html>>;
      ep + "?c_i=" + math:base64encode(im.encode())
    }
  }
  rule create_invitation {
    select when sovrin need_invitation
    pre {
      the_invitation = invitation()
      im = the_invitation
        .split("c_i=").klog("split")
        [1].klog("tail")
        .math:base64decode().klog("base64decode")
        .decode().klog("decode")
      timestamp = time:now()
      auto_accept = event:attr("auto_accept") => true | false
      record = { "invitation": im, "auto_accept": auto_accept }
    }
    send_directive("_txt",{"content":the_invitation})
    fired {
      ent:created_invitations{timestamp} := record
    }
  }
  rule route_new_message {
    select when sovrin new_message protected re#(.*)# setting(protected)
    pre {
      tolog = klog(event:attrs.keys(),"event:attrs.keys()")
      outer = math:base64decode(protected).klog("outer")
      msg = indy:unpack(event:attrs,meta:eci).klog("entire message"){"message"}.decode()
      msg_type = msg{"@type"}.klog("msg_type")
      event_type = a_msg:specToEventType(msg_type)
    }
    if event_type then
      send_directive("message routed",{"event_type":event_type})
    fired {
      raise sovrin event event_type attributes msg
    }
  }
  rule handle_connections_request {
    select when sovrin connections_request label re#(.+)# setting(label)
    pre {
      req_id = event:attr("@id").klog("req_id")
      connection = event:attr("connection").klog("connection")
      publicKeys = connection{["DIDDoc","publicKey"]}
        .map(function(x){x{"publicKeyBase58"}}).klog("publicKeys")
      se = connection{["DIDDoc","service"]}.head(){"serviceEndpoint"}.klog("se")
      chann = agent_Rx()
      my_did = chann{"id"}.klog("my_did")
      my_vk = chann{["sovrin","indyPublic"]}.klog("my_vk")
      endpoint = sEp(my_did).klog("endpoint")
      rm = a_msg:connResMap(req_id, my_did, my_vk, endpoint)
        .klog("response message")
      pm = indy:pack(rm.encode(),publicKeys,meta:eci)
        .klog("packed message")
    }
    http:post(se,body=pm) setting(http_response)
  }
  rule accept_invitation {
    select when sovrin new_invitation url re#(http.+)# setting(url)
    pre {
      qs = url.split("?").tail().join("?").klog("qs")
      args = qs.split("&").klog("args")
        .map(function(x){x.split("=")}).klog("mapped")
        .collect(function(x){x[0]}).klog("collected")
        .map(function(x){x[0][1]}).klog("flattened")
      c_i = args{"c_i"}.klog("c_i")
      im = math:base64decode(c_i).decode().klog("im")
      chann = agent_Rx()
      my_did = chann{"id"}.klog("my_did")
      my_vk = chann{["sovrin","indyPublic"]}.klog("my_vk")
      rm = a_msg:connReqMap(
        label,
        my_did,
        my_vk,
        sEp(my_did)
      ).klog("rm")
      reqURL = im{"serviceEndpoint"}.klog("reqURL")
      packedBody = indy:pack(
        rm.encode().klog("rm encoded"),
        im{"recipientKeys"}.klog("key"),
        my_did
      ).klog("packedBody")
    }
    http:post(reqURL,body=packedBody) setting(http_response)
    fired {
      klog(http_response,"http_response")
    }
  }
  rule handle_connections_response {
    select when sovrin connections_response
    pre {
      connection = a_msg:verify_signatures(event:attrs)
      .klog("connection")
    }
  }
}
