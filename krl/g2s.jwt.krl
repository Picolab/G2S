ruleset jwt {
  meta {
    shares __testing, test_jwt, hashFunctions
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "test_jwt" }
      , { "name": "hashFunctions" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    hashFunctions = function(){
      math:hashFunctions()
    }
    base64url = function(s){
      math:base64encode(s)
        .replace(re#=+$#,"")
        .replace(re#\+#g,"-")
        .replace(re#/#g,"_")
    }
    make_jwt = function(header,payload,secret){
      base64url(header.encode().klog("header")) + "."
      + base64url(payload.encode().klog("payload")) + "."
      + secret // HMAC which we cannot currently do
    }
    sign_jwt = function(jwt){
      math:hash("sha256",jwt)
    }
    test_jwt = function(){
      header = {
        "alg": "HS256",
        "typ": "JWT"
      };
      payload = {
        "id": 1337,
        "username": "?oh>.doe"
      };
      jwt = make_jwt(header,payload,"secretKey").klog("jwt");
      pieces = jwt.split(re#[.]#);
      pieces.splice(2,1,math:base64encode(sign_jwt(jwt))).join(".")
    }
  }
}
