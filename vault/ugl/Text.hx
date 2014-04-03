package vault.ugl;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import vault.EMath;

enum TextAlign {
  TOP_LEFT;
  MIDDLE_LEFT;
  BOTTOM_LEFT;
  TOP_CENTER;
  MIDDLE_CENTER;
  BOTTOM_CENTER;
  TOP_RIGHT;
  MIDDLE_RIGHT;
  BOTTOM_RIGHT;
}

class Text extends Entity {
  var _text: String;
  var _align: TextAlign;
  var _redraw: Bool;
  var _size: Int;
  var _duration: Float;
  var _color: UInt;

  public function new() {
    super();
    _align = MIDDLE_CENTER;
    _text = "";
    _redraw = true;
    _size = 1;
    _color = 0xFFFFFFFF;
    _duration = Math.NaN;
  }

  public function text(s: String): Text {
    _text = s;
    _redraw = true;
    return this;
  }

  public function xy(x: Float, y: Float): Text {
    pos.x = x;
    pos.y = y;
    return this;
  }

  public function move(x: Float, y: Float): Text {
    vel.x = x;
    vel.y = y;
    return this;
  }

  public function align(a: TextAlign): Text {
    _align = a;
    return this;
  }

  public function size(s: Int): Text {
    _size = s;
    _redraw = true;
    return this;
  }

  public function color(c: UInt): Text {
    _color = c;
    _redraw = true;
    return this;
  }

  public function duration(v: Float): Text {
    _duration = v;
    return this;
  }

  function redraw() {
    sprite.graphics.clear();
    if (_text.length == 0) return;

    _redraw = false;
    var bmpd = Text.drawText(_text, _color, _size);
    sprite.graphics.beginBitmapFill(bmpd, null, false, false);
    sprite.graphics.drawRect(0, 0, bmpd.width, bmpd.height);
  }

  override public function update() {
    super.update();
    if (_redraw) {
      redraw();
      if (_redraw) return;
    }

    if (!Math.isNaN(_duration)) {
      _duration -= Game.time;
      if (_duration <= 0) {
        remove();
      }
    }

    deltasprite.x = switch (_align) {
      case TOP_LEFT | MIDDLE_LEFT | BOTTOM_LEFT: Math.ceil(sprite.width/2);
      case TOP_CENTER | MIDDLE_CENTER | BOTTOM_CENTER: 0;
      case TOP_RIGHT | MIDDLE_RIGHT | BOTTOM_RIGHT: -Math.floor(sprite.width/2);
    }

    deltasprite.y = switch (_align) {
      case TOP_LEFT | TOP_CENTER | TOP_RIGHT: Math.ceil(sprite.height/2);
      case MIDDLE_LEFT | MIDDLE_CENTER | MIDDLE_RIGHT: 0;
      case BOTTOM_LEFT | BOTTOM_CENTER | BOTTOM_RIGHT: -Math.floor(sprite.height/2);
    }
  }

  static public function drawText(text: String, color: Int, size: Int): BitmapData {
    var bmpd = new BitmapData(size*text.length*FONTWIDTH, size*FONTHEIGHT, true, 0);

    var curx = 0;
    var maxx = 0;
    for (i in 0...text.length) {
      var c = text.charCodeAt(i);
      if (c <= 32 || c > 126) { c = 32; maxx += FONTWIDTH*size; }
      for (p in 0...FONTWIDTH*FONTHEIGHT) {
        var v:UInt = FONTDATA[(c-32)*2 + Std.int(p/32)] & 1 << (31-(p%32));
        if (v != 0) {
          var px = curx + (p%FONTWIDTH) * size;
          maxx = EMath.max(maxx, px);
          var py = Std.int(p/FONTWIDTH) * size;
          bmpd.fillRect(new Rectangle(px, py, size, size), color);
        }
      }
      curx = maxx + 2*size;
    }

    var out = new BitmapData(curx, bmpd.height, true, 0);
    out.copyPixels(bmpd, out.rect, new flash.geom.Point(0, 0));
    return out;
  }

  static var FONTWIDTH = 6;
  static var FONTHEIGHT = 8;
  // Based on Minecraftia.ttf
  static var FONTDATA = [
    0x00000000, 0x00000000, 0x82082080, 0x08000000, 0x514a0000, 0x00000000,
    0x514f94f9, 0x45000000, 0x21e81c0b, 0xc2000000, 0x8a410841, 0x28800000,
    0x21421ab2, 0x46800000, 0x41080000, 0x00000000, 0x31082081, 0x03000000,
    0xc0810410, 0x8c000000, 0x00091890, 0x00000000, 0x00823e20, 0x80000000,
    0x00000002, 0x08200000, 0x00003e00, 0x00000000, 0x00000002, 0x08000000,
    0x08410841, 0x08000000, 0x7229aaca, 0x27000000, 0x21820820, 0x8f800000,
    0x72208c42, 0x2f800000, 0x72208c0a, 0x27000000, 0x18a4a2f8, 0x20800000,
    0xfa0f020a, 0x27000000, 0x31083c8a, 0x27000000, 0xfa208420, 0x82000000,
    0x72289c8a, 0x27000000, 0x72289e08, 0x46000000, 0x02080002, 0x08000000,
    0x02080002, 0x08200000, 0x10842040, 0x81000000, 0x000f8003, 0xe0000000,
    0x81020421, 0x08000000, 0x72208420, 0x02000000, 0x7a1b6dbe, 0x07800000,
    0x7228be8a, 0x28800000, 0xf22f228a, 0x2f000000, 0x72282082, 0x27000000,
    0xf228a28a, 0x2f000000, 0xfa0e2082, 0x0f800000, 0xfa0e2082, 0x08000000,
    0x7a0ba28a, 0x27000000, 0x8a2fa28a, 0x28800000, 0xe1041041, 0x0e000000,
    0x0820820a, 0x27000000, 0x8a4e248a, 0x28800000, 0x82082082, 0x0f800000,
    0x8b6aa28a, 0x28800000, 0x8b2aa68a, 0x28800000, 0x7228a28a, 0x27000000,
    0xf22f2082, 0x08000000, 0x7228a28a, 0x46800000, 0xf22f228a, 0x28800000,
    0x7a07020a, 0x27000000, 0xf8820820, 0x82000000, 0x8a28a28a, 0x27000000,
    0x8a28a251, 0x42000000, 0x8a28a2ab, 0x68800000, 0x8942148a, 0x28800000,
    0x89420820, 0x82000000, 0xf8210842, 0x0f800000, 0xe2082082, 0x0e000000,
    0x81040810, 0x40800000, 0xe0820820, 0x8e000000, 0x21488000, 0x00000000,
    0x00000000, 0x0f800000, 0x82040000, 0x00000000, 0x0007027a, 0x27800000,
    0x820b328a, 0x2f000000, 0x00072282, 0x27000000, 0x0826a68a, 0x27800000,
    0x000722fa, 0x07800000, 0x310f1041, 0x04000000, 0x0007a289, 0xe0bc0000,
    0x820b328a, 0x28800000, 0x80082082, 0x08000000, 0x0800820a, 0x289c0000,
    0x820928c2, 0x89000000, 0x82082082, 0x04000000, 0x000d2aaa, 0x28800000,
    0x000f228a, 0x28800000, 0x0007228a, 0x27000000, 0x000b328b, 0xc8200000,
    0x0006a689, 0xe0820000, 0x000b3282, 0x08000000, 0x0007a070, 0x2f000000,
    0x410e1041, 0x02000000, 0x0008a28a, 0x27800000, 0x0008a289, 0x42000000,
    0x0008a2aa, 0xa7800000, 0x00089421, 0x48800000, 0x0008a289, 0xe0bc0000,
    0x000f8421, 0x0f800000, 0x31042041, 0x03000000, 0x82080082, 0x08000000,
    0xc0820420, 0x8c000000, 0x66600000, 0x00000000,
  ];
}
