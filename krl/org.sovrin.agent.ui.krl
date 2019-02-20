ruleset org.sovrin.agent.ui {
  meta {
    use module html
    shares __testing, html
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "html", "args": [ "c_i" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    html = function(c_i){
      invite = math:base64decode(c_i);
      explain = "<p>You are looking at an invitation</p>";
      html:header("invitation") + explain + invite + html:footer()
    }
  }
  rule display_instructions {
    select when sovrin pending_invitation c_i re#(.+)# setting(c_i)
    every {
      send_directive("instructions");
      send_directive("_html",{"content":html(c_i)})
    }
  }
}
