package vault;

class EMath {
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
    return f < a ? a : ( f > b ? b : f);
  }

  static public inline function PowerOf2(n: Float): Int {
    return Math.round(Math.pow(2, Math.ceil(Math.log(n)/Math.log(2))));
  }

  static public inline function sign(f: Float): Int {
    return f >= 0 ? 1 : -1;
  }
}
