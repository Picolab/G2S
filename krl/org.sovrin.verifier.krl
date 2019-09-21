ruleset org.sovrin.verifier {
  meta {
    use module org.sovrin.agent alias agent
    shares __testing, nameForDID
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "nameForDID", "args": [ "did" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    nameForDID = function(did){
      connections = agent:ui(){"connections"};
      name = connections.isnull()
        => null
         | connections
             .filter(function(c){c{"my_did"}==did})
             .head(){"label"}
         ;
      name => name | ""
    }
  }
}
