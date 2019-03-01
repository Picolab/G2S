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
    invite = function(map){
      <<<pre>
<script type="text/javascript">document.write(JSON.stringify(#{map},null,2))</script>
</pre>
>>
    }
    scripts = <<<script src="/js/jquery-3.1.0.min.js"></script>
<!-- thanks to Jerome Etienne http://jeromeetienne.github.io/jquery-qrcode/ -->
<script type="text/javascript" src="/js/jquery.qrcode.js"></script>
<script type="text/javascript" src="/js/qrcode.js"></script>
<script type="text/javascript">
$(function(){
  $("div").qrcode({ text: location.href, foreground: "#000000" });
});
</script>
>>
    explain = function(owner){
      <<<p>You are looking at an invitation from #{owner}.
(wait, <a href="#confusion"><em>I'm</em> #{owner}!</a>)</p>
<p>You received this invitation because #{owner} wants to have a
secure message connection with you.
To accept the invitation, you must have the <em>Pico Agent App</em>
(or another <a href="https://sovrin.org/">Sovrin</a>-compatible agent app).</p>
<p>Using your agent app, either scan the QR Code below,
or copy the URL from the location bar of your browser
and paste it into your app.</p>
>>
    }
    html = function(c_i){
      map = math:base64decode(c_i);
      owner = map.decode(){"label"};
      html:header("invitation", scripts) + explain(owner)
        + <<<div style="border:1px dashed silver;padding:5px;width:max-content"></div>
>>
        + <<<p>Technical details:</p>
>>
        + invite(map)
        + <<<a name="confusion"><p>You're #{owner}:</p></a>
<p>You'll need to give this URL to the person with whom you want
a secure message-passing connection.
Or, just have them use their Pico Agent App to scan the QR Code above.</p>
>>
        + html:footer()
    }
  }
}
