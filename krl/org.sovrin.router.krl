ruleset org.sovrin.router {
  meta {
    use module org.sovrin.agent alias agent
    shares __testing, stored_msg
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
    connection = function(vk){
      agent:connections()
        .filter(function(x){x{"their_vk"} == vk })
        .head()
    }
    stored_msg = function(vk){
      ent:stored_msgs{vk}
    }
  }
//
// forward a message to a connection
//
  rule store_or_forward_routed_message {
    select when sovrin routing_forward
    pre {
      to = event:attr("to").klog("to")
      pm = event:attr("msg").klog("pm")
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
}
