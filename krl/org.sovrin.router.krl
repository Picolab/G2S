ruleset org.sovrin.router {
  meta {
    use module org.sovrin.agent_message alias a_msg
    use module io.picolabs.wrangler alias wrangler
    shares __testing, stored_msg
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "stored_msg", "args": [ "vk" ] }
      ] , "events":
      [ { "domain": "router", "type": "request", "attrs": [ "label", "final_key"] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    connection = function(vk){
      ent:routingConnections.defaultsTo({})
        .values()
        .filter(function(x){x{"their_vk"} == vk})
        .head()
    }
    stored_msg = function(vk){
      ent:stored_msgs{vk}.decode()
    }
  }
//
// initialize router
//
  rule initialize_router {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    // TODO need a policy that allows only router/request
    wrangler:createChannel(meta:picoId,"router_request","well_known")
      setting(channel)
  }
//
// forward a message to a connection
//
  rule store_or_forward_routed_message {
    select when sovrin routing_forward
    pre {
      message = event:attr("message")
      to = message{"to"}.klog("to")
      pm = message{"msg"}.klog("pm")
      se = connection(to){"their_endpoint"}.klog("se")
    }
    if se then noop()
    fired {
      raise sovrin event "new_ssi_agent_wire_message" attributes {
        "serviceEndpoint": se, "packedMessage": pm
      }
    } else {
      ent:stored_msgs{to} := pm
    }
  }
//
// handle a new routing request
//
  rule handle_new_routing_request {
    select when router request final_key re#(.+)# setting(final_key)
    pre {
      their_label = event:attr("label")
      endpoint = event:attr("endpoint")
      c = {
        "created": time:now(),
        "label": their_label,
        "their_vk": final_key,
        "their_endpoint": endpoint,
      }
    }
    if c && their_label then
      wrangler:createChannel(meta:picoId,their_label,"inbound_route")
        setting(channel)
    fired {
      raise router event "request_accepted"
        attributes { "conn": c, "channel": channel }
    }
  }
  rule respond_to_routing_request {
    select when router request_accepted
    pre {
      channel = event:attr("channel")
      my_did = channel{"id"}
      conn = event:attr("conn")
      final_key = conn{"their_vk"}
      routing = [channel{["sovrin","indyPublic"]}]
      connection = conn
        .put({
          "my_did": my_did,
          "their_routing": routing,
        })
    }
    fired {
      ent:routingConnections := ent:routingConnections.defaultsTo({})
        .put([final_key],connection);
      raise router event "request_recorded" attributes {"vk": final_key}
    }
  }
  rule return_the_routed_connection {
    select when router request_recorded vk re#(.+)# setting(vk)
    send_directive("request accepted",{"connection": connection(vk)})
  }
}
