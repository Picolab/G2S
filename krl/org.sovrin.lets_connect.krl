ruleset org.sovrin.lets_connect {
  global {
    pattern = re#(http.+[?].*c_i=.+)#
  }
//
// check for already canonical
//
  rule guard_for_canonicity {
    select when sovrin new_invitation
      url re#(http.+[?].*c_i=.+)# setting(url)
    if url.klog("canonical") then noop()
    fired {
      last
    }
  }
//
// convert any Let's connect url into an canonical one
//
  rule accept_let_s_connect_invitation {
    select when sovrin new_invitation
      url re#Let.s connect.*(https://.*)#i setting(url)
    pre {
      res = http:get(url.klog("url"),dontFollowRedirect=true).klog("res")
      ok = res{"status_code"}.klog("status_code") == 200
      location = ok => res{"content"} | null
    }
    if ok && location.klog("location") && location.match(pattern) then noop()
    fired {
      raise sovrin event "new_invitation"
        attributes event:attrs.put("url",location)
    }
  }
}
