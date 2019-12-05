ruleset org.sovrin.agent_bc {
  meta {
    use module org.sovrin.agent alias agent
    shares __testing, invitation, connections
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "invitation" }
      , { "name": "connections" }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    invitation = function(){
      agent:ui(){"invitation"}
    }
    connections = function(){
      agent:ui(){"connections"}
        .map(function(c){c{"label"}})
    }
  }
}
