package vault.ugl;

import hxColorToolkit.spaces.*;

class Color implements traits.IStatics {
  static public function lerp(fromColor: UInt, toColor: UInt, ratio: Float) {
    if (ratio <= 0) { return fromColor; }
    if (ratio >= 1) { return toColor; }

    var f2:Int = Std.int(256 * ratio);
    var f1:Int = Std.int(256 - f2);

    return ((((( fromColor & 0xFF00FF ) * f1 ) + ( ( toColor & 0xFF00FF ) * f2 )) >> 8 ) & 0xFF00FF ) |
           ((((( fromColor & 0x00FF00 ) * f1 ) + ( ( toColor & 0x00FF00 ) * f2 )) >> 8 ) & 0x00FF00 );
  }

  /**
   * Lerp from @fromColor to @toColor, keeping @fromColor luminosity.
  */
  static public function lerpValue(fromColor: UInt, toColor: UInt, ratio: Float) {
    if (ratio <= 0) { return fromColor; }
    if (ratio >= 1) { return toColor; }

    var c1 = new Lab().setColor(fromColor);
    var c2 = new Lab().setColor(toColor);

    var r = new Lab(c1.lightness, c1.a + (c2.a - c1.a)*ratio,
                                  c1.b + (c2.b - c1.b)*ratio);
    return r.getColor();
  }


  static public function LAB(l: Float, a: Float, b: Float): UInt {
    var col = new Lab(l, a, b);
    return col.getColor();
  }

  /**
   * Returns a Color from a HSV value (0-360, 0-1, 0-1)
   */
  static public function HSV(hue: Float, saturation: Float, value: Float): UInt {
    var col = new HSB(hue, saturation*100, value*100);
    return col.getColor();
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
