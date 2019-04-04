ruleset org.sovrin.agency.ui {
  meta {
    use module html
    use module colors
    provides html, invitation
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      ] , "events": []
    }
    styles = <<<style type="text/css">
select:invalid {
  color: gray;
}
form:invalid button {
  visibility: hidden;
}
</style>
>>
    colorOptions = colors:colorsMap.map(function(c,n){
      <<<option value="#{c}">#{n}</option>
>>
    }).values().join("")
    html = function(name){
      html:header(name,styles)
        + <<<h1>#{name}</h1>
<h2>New Agent</h2>
>>
        + <<<form action="/sky/event/#{meta:eci}/none/agency/new_agent">
<input name="name" type="email" placeholder="email address" required>
<select name="color" required>
<option value="" disabled selected hidden>color</option>
#{colorOptions}</select>
<input name="label" placeholder="label" required>
<button type="submit">agency/new_agent</button>
</form>
>>
        + html:footer()
    }
    invitation = function(name,did){
      js = "document.execCommand('selectAll',false,null);"
         + "document.execCommand('copy')";
      html:header(name)
      + <<<pre>#{name}, your DID is <span id="did" contenteditable
      onclick="#{js}">#{did}</span></pre>
>>
      + <<<p>Click anywhere in the DID and then click on the "login" button.</p>
<button type="button" onclick="location='#{meta:host}'">login</button>
>>
      + html:footer()
    }
  }
}
