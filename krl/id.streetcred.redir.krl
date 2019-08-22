ruleset id.streetcred.redir {
  global {
    prefix = re#^id.streetcred://launch/[?]c_i=.+#
  }
//
// convert streetcred invitation into one acceptable to Agent Pico
//
  rule accept_streetcred_invitation {
    select when sovrin new_invitation
      url re#(https://redir.streetcred.id/.+)# setting(url)
    pre {
      res = http:get(url,dontFollowRedirect=true)
      ok = res{"status_code"} == 302
      location = ok => res{["headers","location"]} | null
    }
    if location && location.match(prefix) then noop()
    fired {
      raise sovrin event "new_invitation"
        attributes event:attrs.put("url","http://"+location)
    }
  }
}
