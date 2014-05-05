package vault.ugl;

class Color implements traits.IStatics {
  static public function lerp(fromColor: Int, toColor: Int, ratio: Float) {
    if (ratio <= 0) { return fromColor; }
    if (ratio >= 1) { return toColor; }

    var f2:Int = Std.int(256 * ratio);
    var f1:Int = Std.int(256 - f2);

    return ((((( fromColor & 0xFF00FF ) * f1 ) + ( ( toColor & 0xFF00FF ) * f2 )) >> 8 ) & 0xFF00FF ) |
           ((((( fromColor & 0x00FF00 ) * f1 ) + ( ( toColor & 0x00FF00 ) * f2 )) >> 8 ) & 0x00FF00 );
   }
}

class ColorsArne extends Color {
  static public var black = 0x000000;
  static public var white = 0xFFFFFF;
  static public var grey = 0x9d9d9d;
  static public var darkgrey = 0x697175;
  static public var lightgrey = 0xcccccc;
  static public var red = 0xbe2633;
  static public var darkred = 0x732930;
  static public var lightred = 0xe06f8b;
  static public var brown = 0xa46422;
  static public var darkbrown = 0x493c2b;
  static public var lightbrown = 0xeeb62f;
  static public var orange = 0xeb8931;
  static public var yellow = 0xf7e26b;
  static public var green = 0x44891a;
  static public var darkgreen = 0x2f484e;
  static public var lightgreen = 0xa3ce27;
  static public var blue = 0x1d57f7;
  static public var lightblue = 0xB2DCEF;
  static public var darkblue = 0x1B2632;
  static public var purple = 0x342a97;
  static public var pink = 0xde65e2;
}
