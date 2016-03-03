package vault;

class EMath {
  static public inline var SQRT2 = 1.4142135623730950;
  static public inline var MAX_INT: Int = 2147483647;

  static public inline function min(a, b):Int {
    return a < b ? a : b;
  }

  static public inline function max(a, b):Int {
    return a > b ? a : b;
  }

  static public inline function abs(x: Int): Int {
    return (x ^ (x >> 31)) - (x >> 31);
  }

  static public inline function fabs(x: Float): Float {
    return x < 0 ? -x : x;
  }

  static public inline function int(x: Float): Int {
    return Std.int(x);
  }

  static public inline function clamp(f:Float, a:Float, b:Float):Float {
    return f <= a ? a : ( f >= b ? b : f);
  }

  static public inline function clampi(f:Int, a:Int, b:Int):Int {
    return f <= a ? a : ( f >= b ? b : f);
  }

  static public inline function PowerOf2(n: Float): Int {
    return Math.round(Math.pow(2, Math.ceil(Math.log(n)/Math.log(2))));
  }

  static public inline function sign(f: Float): Int {
    return f >= 0 ? 1 : -1;
  }

  static public inline function abssign(x: Int): Int {
    return x < 0 ? -1 : x > 0 ? 1 : 0;
  }

  static public inline function angledistance(from: Float, to: Float): Float {
    var delta = (to - from) % (2*Math.PI);
    if (delta < 0) delta += 2*Math.PI;
    if (delta > Math.PI) delta -= 2*Math.PI;
    return -delta;
  }
}
