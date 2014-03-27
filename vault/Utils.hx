package vault;

class Utils {

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

  public static function colorLerp(fromColor:UInt, toColor:UInt, t:Float = 1):UInt {
    if (t <= 0) { return fromColor; }
    if (t >= 1) { return toColor; }

    var f2:Int = Std.int(256 * t);
    var f1:Int = Std.int(256 - f2);

    return ((((( fromColor & 0xFF00FF ) * f1 ) + ( ( toColor & 0xFF00FF ) * f2 )) >> 8 ) & 0xFF00FF ) |
           ((((( fromColor & 0x00FF00 ) * f1 ) + ( ( toColor & 0x00FF00 ) * f2 )) >> 8 ) & 0x00FF00 );
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
