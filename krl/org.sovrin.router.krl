ruleset org.sovrin.router {
  meta {
    use module org.sovrin.agent_message alias a_msg
    use module io.picolabs.wrangler alias wrangler
    shares __testing, stored_msgs
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "stored_msgs", "args": [ "vk", "exceptions" ] }
      ] , "events":
      [ { "domain": "router", "type": "request", "attrs": [ "label", "final_key"] }
      , { "domain": "router", "type": "messages_not_needed", "attrs": [ "vk", "msgTags" ] }
      ]
    }
    connection = function(vk){
      ent:routingConnections
        .values()
        .filter(function(x){x{"their_vk"} == vk})
        .head()
    }
    stored_msgs = function(vk,exceptions){
      msgTags = exceptions.decode(); // expecting an Array of Strings
      except = function(x){
        not (msgTags >< x.decode(){"tag"})
      };
      all_msgs = ent:stored_msgs{vk};
      msgTags.isnull() => all_msgs
                        | all_msgs.filter(except)
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
    fired {
      ent:stored_msgs := {};
      ent:routingConnections := {}
    }
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
      ent:stored_msgs{to} := ent:stored_msgs{to}.defaultsTo([]).append(pm)
    }
  }
  rule clean_up_stored_messages {
    select when router messages_not_needed vk re#(.+)# setting(vk)
    pre {
      my_did = ent:routingConnections{[vk,"my_did"]}
      msgTags = event:attr("msgTags").decode()
      remaining = ent:stored_msgs{vk}.filter(function(x){
        not (msgTags >< x.decode(){"tag"})
      })
    }
    if meta:eci == my_did then
      send_directive("clean_up_complete",{
        "remove": msgTags.length(),
        "were": ent:stored_msgs{vk}.length(),
        "remaining": remaining.length(),
      })
    fired {
      ent:stored_msgs{vk} := remaining
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
      ent:routingConnections{final_key} := connection;
      raise router event "request_recorded" attributes {"vk": final_key}
    }
  }
  rule return_the_routed_connection {
    select when router request_recorded vk re#(.+)# setting(vk)
    send_directive("request accepted",{"connection": connection(vk)})
  }
}
