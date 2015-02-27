package vault;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
#end

class Utils {

  public static function initGrid<T>(width: Int, height: Int): Array<Array<T>> {
    var ret = new Array<Array<T>>();
    for (x in 0...width) {
      var col = new Array<T>();
      for (y in 0...height) {
        col.push(null);
      }
      ret.push(col);
    }
    return ret;
  }

  public static function initArray<T>(num: Int, def:T): Array<T> {
    var ar = new Array<T>();
    for (i in 0...num) {
      ar.push(def);
    }
    return ar;
  }

  public static function timeit() {
    var t = haxe.Timer.stamp();
    return function(s: String) {
      trace(s + ": " + (haxe.Timer.stamp() - t));
    }
  }

  public static function timeToMS(t: Float): String {
    var r = "";
    if (t > 3600) {
      r += Math.floor(t/3600) + ":";
      t %= 3600;
    }
    if (t > 60) {
      r += Math.floor(t/60) + ":";
      t %= 60;
    } else {
      r += "0:";
    }
    if (t < 10) {
      r += "0";
    }
    r += Math.floor(t);
    t %= 1;

    return r;
  }

  public static function shuffle<T1>(array: Array<T1>): Array<T1> {
    var counter = array.length;

    // While there are elements in the array
    while (counter-- > 0) {
        // Pick a random index
        var index = Math.floor((Math.random() * counter));

        // And swap the last element with it
        var temp = array[counter];
        array[counter] = array[index];
        array[index] = temp;
    }
    return array;
  }
}
