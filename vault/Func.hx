package vault;

class Func {
  // CPS-style Map function for succ/fail.
  // Calls @func with each element of @list with CPS in @succ and @fail.
  static public function sfMap<T>(list: Array<T>,
                                  func: T -> (Void->Void) -> (Void->Void) -> Void,
                                  succ: Void->Void, fail: Void->Void) {
    var l = list.copy();
    var rec: Void->Void = null;
    rec = function()return func(l.pop(), function() {
        if (l.length == 0) return succ();
        rec();
      }, fail);
    return rec();
  }

}
