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
      <<<p>You are #{owner}. (<a href="#urk">Not #{owner}?</a>)</p>
<p>You are looking at an invitation that you can give to someone else
who has the pico agent app.</p>
<p>Have them either scan the QR Code below, or email them the content
of the location bar of your browser.</p>
>>
    }
    html = function(c_i){
      map = math:base64decode(c_i);
      html:header("invitation", scripts) + explain(map.decode(){"label"})
        + <<<div style="border:1px dashed silver;padding:5px;width:max-content"></div>
>>
        + <<<p>Technical details:</p>
>>
        + invite(map)
        + html:footer()
    }
  }
}
