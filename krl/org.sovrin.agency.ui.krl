ruleset org.sovrin.agency.ui {
  meta {
    use module html
    use module colors
    provides html
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      ] , "events": []
    }
    colorOptions = colors:colorsMap.map(function(c,n){
      <<<option value="#{c}">#{n}</option>
>>
    }).values().join("")
    html = function(){
      html:header("New Agent")
        + <<<h1>New Agent</h1>
>>
        + <<<form action="/sky/event/#{meta:eci}/none/agency/new_agent">
<input name="name" placeholder="email address">
<select name="color">
<option value="">color</option>
#{colorOptions}</select>
<input name="label" placeholder="label">
<input type="submit" value="agency/new_agent">
</form>
>>
        + html:footer()
    }
  }
}
