package vault.ugl;

class Score {
  public function new(score: Float, ?final = false) {
    post(score, final);
  }

#if html5
  function post(score: Float, ?final = false) {
    try {
      var f = untyped __js__("window.parent.uglScore");
      f(score, final);
    } catch(e: Dynamic) { }
  }
#end

#if flash
  function post(score: Float, ?final = false) {
    try {
      flash.external.ExternalInterface.call("window.uglScore", score, final);
    } catch(e: Dynamic) { }
  }
#end

#if (!flash && !html5)
  function post(score: Float, ?final = false) {
  }
#end

}
