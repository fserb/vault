package vault.ugl;

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import vault.Utils;

class PixelArt {
  var sprite: Sprite;
  public var disabled: Bool = false;
  var cacheIndex: Int = -1;

  public function new(base: Sprite) {
    sprite = base;
    disabled = false;
    cacheIndex = -1;
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
    if (disabled) return this;
    this.px = px;
    if (w > 0 || h > 0) {
      _width = w; _height = h;
      clear();
    }
    return this;
  }

  /**
   * @c : first color
   * @c2 : second color
   * @pat : color pattern (X|XY|XYB)
   *        where B is for both X and Y.
   */
  public function color(c: UInt, ?c2: Int = -1, ?pat: Int = 0): PixelArt {
    if (disabled) return this;
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
    sprite.graphics.clear();
    sprite.graphics.beginFill(0x000000, 0.0);
    sprite.graphics.drawRect(0, 0, _width*px, _height*px);
    disabled = false;
    cacheIndex = -1;
    return this;
  }

  public function cache(idx: Int): PixelArt {
    if (idx == cacheIndex) {
      disabled = true;
    } else {
      cacheIndex = idx;
      clear();
    }
    return this;
  }

  public inline function dot(x: Float, y: Float): PixelArt {
    var v = 0;
    if (_xpat > 0) v += Std.int(x) % _xpat;
    if (_ypat > 0) v += Std.int(y) % _ypat;
    if (_xypat > 0) v += Std.int(x + y) % _xypat;
    sprite.graphics.beginFill(v%2 == 0 ? _color : _alternate_color, 1.0);
    sprite.graphics.drawRect(x*px, y*px, px, px);
    return this;
  }

  public inline function obj(colors: Array<Int>, data: String): PixelArt {
    if (disabled) return this;

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
    if (disabled) return this;
    for (j in 0...Math.round(h)) {
      for (i in 0...Math.round(w)) {
        dot(x+i, y+j);
      }
    }
    return this;
  }

  public function lrect(x: Float, y: Float, w: Float, h: Float): PixelArt {
    if (disabled) return this;
    vline(x, y, y + h);
    vline(x + w, y, y + h);
    hline(x, x + w, y);
    hline(x, x + w, y + h);
    return this;
  }

  public function vline(x: Float, y0: Float, y1: Float): PixelArt {
    if (disabled) return this;
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
    if (disabled) return this;
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
    if (disabled) return this;
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
    if (disabled) return this;
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

  public function text(x: Float, y: Float, text: String, ?size: Int = 1): PixelArt {
    if (disabled) return this;
    x += 0.5;
    y += 0.5;
    var bmpd = Text.drawText(text, 0xFF000000 | _color, size);
    var m = new Matrix();
    m.translate((x*px - bmpd.width/2), (y*px - bmpd.height/2));
    sprite.graphics.beginBitmapFill(bmpd, m, false, false);
    sprite.graphics.drawRect(x*px - bmpd.width/2, y*px - bmpd.height/2, bmpd.width, bmpd.height);
    return this;
  }
}
