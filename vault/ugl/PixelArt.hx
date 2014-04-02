package vault.ugl;

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import vault.Utils;

typedef C = ColorMap;

class PixelArt extends Sprite {
  public function new() {
    super();
    clear();
    _color = 0xFFFFFF;
    _alternate_color = 0xFFFFFF;
    px = 1;
    _xpat = _ypat = _xypat = 0;
    _width = 0;
    _height = 0;
  }

  var _color: UInt;
  var _alternate_color: UInt;
  var px: Int;
  var _xpat: Int;
  var _ypat: Int;
  var _xypat: Int;
  var _width: Int;
  var _height: Int;

  public function size(px: Int = 1, ?w: Int = 0, ?h: Int = 0): PixelArt {
    this.px = px;
    _width = w; _height = h;
    clear();
    return this;
  }

  /**
   * @c : first color
   * @c2 : second color
   * @pat : color pattern (X|XY|XYB)
   *        where B is for both X and Y.
   */
  public function color(c: UInt, ?c2: Int = -1, ?pat: Int = 0): PixelArt {
    _color = c;
    _alternate_color = c2 != -1 ? c2 : c;
    var a = pat % 10;
    var b = Std.int(pat / 10) % 10;
    var c = Std.int(pat / 100) % 10;
    if (b == 0 && c == 0) {
      _xpat = a;
      _ypat = _xypat = 0;
    } else if (c == 0) {
      _xpat = b;
      _ypat = a;
      _xypat = 0;
    } else {
      _xpat = c;
      _ypat = b;
      _xypat = a;
    }
    return this;
  }

  public function clear(): PixelArt {
    graphics.clear();
    graphics.beginFill(0x000000, 0.0);
    graphics.drawRect(0, 0, _width*px, _height*px);
    return this;
  }

  public inline function dot(x: Float, y: Float): PixelArt {
    var v = 0;
    if (_xpat > 0) v += Std.int(x) % _xpat;
    if (_ypat > 0) v += Std.int(y) % _ypat;
    if (_xypat > 0) v += Std.int(x + y) % _xypat;
    graphics.beginFill(v%2 == 0 ? _color : _alternate_color, 1.0);
    graphics.drawRect(x*px, y*px, px, px);
    return this;
  }

  public inline function obj(colors: Array<Int>, data: String): PixelArt {
    _alternate_color = _xpat = _ypat = _xypat = 0;
    var x = 0;
    var y = 0;
    for (i in 0...data.length) {
      var c = data.charAt(i);
      if (c == '\n' || c == ' ') continue;
      if (c != '.') {
        _color = colors[Std.parseInt(c)];
        dot(x, y);
      }
      x++;
      if (x >= _width) {
        x = 0;
        y++;
      }
    }
    return this;
  }

  public function rect(x: Float, y: Float, w: Float, h: Float): PixelArt {
    for (j in 0...Math.round(h)) {
      for (i in 0...Math.round(w)) {
        dot(x+i, y+j);
      }
    }
    return this;
  }

  public function lrect(x: Float, y: Float, w: Float, h: Float): PixelArt {
    vline(x, y, y + h);
    vline(x + w, y, y + h);
    hline(x, x + w, y);
    hline(x, x + w, y + h);
    return this;
  }

  public function vline(x: Float, y0: Float, y1: Float): PixelArt {
    if (y1 < y0) {
      var t = y1;
      y1 = y0;
      y0 = t;
    }
    var y = y0;
    while (y <= y1) {
      dot(x, y++);
    }
    return this;
  }

  public function hline(x0: Float, x1: Float, y: Float): PixelArt {
    if (x1 < x0) {
      var t = x1;
      x1 = x0;
      x0 = t;
    }
    var x = x0;
    while (x <= x1) {
      dot(x++, y);
    }
    return this;
  }

  public function circle(x0: Float, y0: Float, r: Float): PixelArt {
    var x = Math.round(r);
    var y = 0;
    var err = 1 - x;
    while (x >= y) {
      hline(x0 - x, x0 + x, y0 + y);
      hline(x0 - y, x0 + y, y0 + x);
      hline(x0 - x, x0 + x, y0 - y);
      hline(x0 - y, x0 + y, y0 - x);
      y++;
      if (err < 0) {
        err += 2 * y + 1;
      } else {
        x--;
        err += 2 * (y - x + 1);
      }
    }
    return this;
  }

  public function lcircle(x0: Float, y0: Float, r: Float): PixelArt {
    var x = Math.round(r);
    var y = 0;
    var err = 1 - x;
    while (x >= y) {
      dot(x0 + x, y0 + y);
      dot(x0 + y, y0 + x);
      dot(x0 - x, y0 + y);
      dot(x0 - y, y0 + x);
      dot(x0 - x, y0 - y);
      dot(x0 - y, y0 - x);
      dot(x0 + x, y0 - y);
      dot(x0 + y, y0 - x);
      y++;
      if (err < 0) {
        err += 2 * y + 1;
      } else {
        x--;
        err += 2 * (y - x + 1);
      }
    }
    return this;
  }

  public function text(x: Float, y: Float, text: String, ?size: Int = 1) {
    x += 0.5;
    y += 0.5;
    var bmpd = Text.drawText(text, 0xFF000000 | _color, size);
    var m = new Matrix();
    m.translate((x*px - bmpd.width/2), (y*px - bmpd.height/2));
    graphics.beginBitmapFill(bmpd, m, false, false);
    graphics.drawRect(x*px - bmpd.width/2, y*px - bmpd.height/2, bmpd.width, bmpd.height);
  }
}

class ColorMap {
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

  static public function lerp(ca: Int, cb: Int, t: Float): Int {
    return Utils.colorLerp(ca, cb, t);
  }
}


