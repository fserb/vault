package vault.ugl;

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;

class PixelArt extends Sprite {
  public function new() {
    super();
    clear();
    _color = 0xFFFFFF;
    _alternate_color = 0xFFFFFF;
    _size = 1;
    _xpat = _ypat = _xypat = 0;
  }

  var _color: UInt;
  var _alternate_color: UInt;
  var _size: Int;
  var _xpat: Int;
  var _ypat: Int;
  var _xypat: Int;

  public function color(c: UInt, ?c2: Int = -1): PixelArt {
    _color = c;
    _alternate_color = c2 != -1 ? c2 : c;
    return this;
  }
  public function pattern(x: Int, y: Int, ?xy: Int = 0) { _xpat = x; _ypat = y; _xypat = xy; return this; }
  public function size(v: Int): PixelArt { _size = v; return this; }

  public function clear(): PixelArt {
    graphics.clear();
    return this;
  }

  public inline function dot(x: Float, y: Float): PixelArt {
    var v = 0;
    if (_xpat > 0) v += Std.int(x) % _xpat;
    if (_ypat > 0) v += Std.int(y) % _ypat;
    if (_xypat > 0) v += Std.int(x + y) % _xypat;
    graphics.beginFill(v%2 == 0 ? _color : _alternate_color, 1.0);
    graphics.drawRect(x*_size, y*_size, _size, _size);
    return this;
  }

  public function fillRect(x: Float, y: Float, w: Float, h: Float): PixelArt {
    for (j in 0...Math.round(h)) {
      for (i in 0...Math.round(w)) {
        dot(x+i, y+j);
      }
    }
    return this;
  }

  public function lineRect(x: Float, y: Float, w: Float, h: Float): PixelArt {
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

  public function fillCircle(x0: Float, y0: Float, r: Float): PixelArt {
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

  public function lineCircle(x0: Float, y0: Float, r: Float): PixelArt {
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
    var bmpd = Text.drawText(text, 0xFF000000 | _color, size);
    var m = new Matrix();
    m.translate((x - bmpd.width/2), (y - bmpd.height/2));
    graphics.beginBitmapFill(bmpd, m, false, false);
    graphics.drawRect(x - bmpd.width/2, y - bmpd.height/2, bmpd.width, bmpd.height);
  }
}
