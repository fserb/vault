package vault;

import hxColorToolkit.ColorToolkit;
import hxColorToolkit.spaces.*;
import vault.geom.Vec3;

class Color {
  static public function lerp(fromColor: UInt, toColor: UInt, ratio: Float): UInt {
    if (ratio <= 0) { return fromColor; }
    if (ratio >= 1) { return toColor; }

    var f2:Int = Std.int(256 * ratio);
    var f1:Int = Std.int(256 - f2);

    return ((((( fromColor & 0xFF00FF ) * f1 ) + ( ( toColor & 0xFF00FF ) * f2 )) >> 8 ) & 0xFF00FF ) |
           ((((( fromColor & 0x00FF00 ) * f1 ) + ( ( toColor & 0x00FF00 ) * f2 )) >> 8 ) & 0x00FF00 );
  }

  static public function delta(fromColor: UInt, toColor: UInt, maxdelta: Float): UInt {
    var f = new Vec3(((fromColor & 0xFF0000) >> 16)/0xFF,
                     ((fromColor & 0x00FF00) >> 8)/0xFF,
                     ((fromColor & 0x0000FF)/0xFF));
    var t = new Vec3(((toColor & 0xFF0000) >> 16)/0xFF,
                     ((toColor & 0x00FF00) >> 8)/0xFF,
                     ((toColor & 0x0000FF)/0xFF));

    var d = t.distance(f);
    d.clamp(maxdelta);
    f.add(d);

    return (Std.int(f.x*0xFF) << 16) + (Std.int(f.y*0xFF) << 8) + Std.int(f.z*0xFF);

  }

  static inline public function HSL(color: UInt): HSL {
    return ColorToolkit.toHSL(color);
  }
}
