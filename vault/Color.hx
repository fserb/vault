package vault;

import hxColorToolkit.ColorToolkit;
import hxColorToolkit.spaces.*;

class Color {
  static public function lerp(fromColor: UInt, toColor: UInt, ratio: Float): UInt {
    if (ratio <= 0) { return fromColor; }
    if (ratio >= 1) { return toColor; }

    var f2:Int = Std.int(256 * ratio);
    var f1:Int = Std.int(256 - f2);

    return ((((( fromColor & 0xFF00FF ) * f1 ) + ( ( toColor & 0xFF00FF ) * f2 )) >> 8 ) & 0xFF00FF ) |
           ((((( fromColor & 0x00FF00 ) * f1 ) + ( ( toColor & 0x00FF00 ) * f2 )) >> 8 ) & 0x00FF00 );
  }

  static public function RGBToHSL(rgb: UInt): Dynamic {
    var c = ColorToolkit.toHSL(rgb);
    return {h: c.hue, s: c.saturation, l: c.lightness};
  }

  static public function HSL(h: Float, s: Float, l: Float): UInt {
    var c = new HSL(h,s,l);
    return c.getColor();
  }
}
