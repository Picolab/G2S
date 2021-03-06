ruleset webfinger {
  meta {
    provides webfinger
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
    wfLink = function(jrd,rel){
      jrd.isnull() => null |
      jrd{"links"}
        .filter(function(x){x{"rel"}==rel})
        .head(){"href"}
    }
    getWF = function(domain,resource){
      rsc = <<acct:#{resource}>>.replace(re#:#,"%3A").replace(re#@#,"%40");
      url = <<https://#{domain}/.well-known/webfinger?resource=#{rsc}>>;
      ans = http:get(url);
      jrd = ans{"status_code"} != 200 => null
          | ans{"content"}.decode();
      profile = wfLink(jrd,"http://webfinger.net/rel/profile-page");
      avatar = wfLink(jrd,"http://webfinger.net/rel/avatar");
      profile.isnull() && avatar.isnull() => null
        | { "photo": avatar, "url": profile }
    }
    webfinger = function(resource){
      domain = resource.extract(re#^[^@]+@(.+)#).head();
      domain.isnull() => null
        | getWF(domain,resource)
    }
  }
}
