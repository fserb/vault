package vault.left;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tilesheet;
import vault.BMFont;
import vault.EMath;
import vault.Vec2;

class Char extends BMFont.BMChar {
  public var image: Image;
}

enum TextAlign {
  LEFT;
  CENTER;
  RIGHT;
}

enum TextVAlign {
  TOP;
  MIDDLE;
  BOTTOM;
}

class Text extends Object {
  public var pos: Vec2;
  public var text(default, set): String = "";
  public var xoffset: Float;
  public var align: TextAlign;
  public var valign: TextVAlign;
  public var scale(default, set): Float = 1.0;
  public var alpha: Float;
  public var width: Float;
  public var height: Float;

  static var repo_font: Map<String, BMFont>;

  var font: BMFont;
  var widths: Array<Float>;

  public function new(fontname: String) {
    pos = Vec2.make(0, 0);
    xoffset = 0.0;
    align = LEFT;
    valign = TOP;
    alpha = 1.0;
    width = 0.0;
    height = 0.0;
    widths = null;

    if (repo_font == null) {
      repo_font = new Map<String, BMFont>();
    }

    if (!repo_font.exists(fontname)) {
      font = BMFont.read(Assets.getText("assets/fonts/" + fontname + ".fnt"));
      var bmd = Assets.getBitmapData("assets/fonts/" + fontname + ".png");
      repo_font.set(fontname, font);
      for (id in font.chars.keys()) {
        var c = new Char(font.chars[id]);
        var b = new BitmapData(c.width, c.height);
        b.copyPixels(bmd, new Rectangle(c.x, c.y, c.width, c.height), new Point(0, 0));
        c.image = Image.create(b);
        c.image.offset.x = -c.xoffset;
        c.image.offset.y = -c.yoffset;
        font.chars[id] = c;
      }
    } else {
      font = repo_font.get(fontname);
    }
  }

  function update_dimensions() {
    var dx = 0.0;
    var dy = 1;
    widths = new Array<Float>();

    for (i in 0...text.length) {
      var cc = text.charCodeAt(i);
      if (cc == 10) {
        widths.push(dx*scale);
        dx = 0.0;
        dy++;
        continue;
      }
      var c: Char = cast font.chars[cc];
      dx += c.xadvance + xoffset;
    }
    widths.push(dx*scale);
    width = 0.0;
    for (w in widths) {
      width = Math.max(width, w);
    }
    height = dy*font.lineHeight*scale;
  }

  public function set_scale(s: Float): Float {
    scale = s;
    update_dimensions();
    return scale;
  }

  public function set_text(t: String): String {
    text = t;
    update_dimensions();
    return text;
  }

  function getAligned(line: Int = 0): Vec2 {
    var v = pos.copy();
    switch (align) {
      case LEFT:
      case CENTER: v.x -= widths[line]/2;
      case RIGHT: v.x -= width;
    }
    switch (valign) {
      case TOP:
      case MIDDLE: v.y -= height/2;
      case BOTTOM: v.y -= height;
    }
    return v;
  }

  override public function render(view: View) {
    var v = getAligned(0);
    var line = 0;
    for (i in 0...text.length) {
      var cc = text.charCodeAt(i);
      if (cc == 10) {
        line++;
        v.x = getAligned(line).x;
        v.y += font.lineHeight*scale;
        continue;
      }
      var c: Char = cast font.chars[cc];
      view.draw(c.image, v.x, v.y, 0.0, scale, scale, alpha);
      v.x += (c.xadvance + xoffset)*scale;
    }
  }
}
