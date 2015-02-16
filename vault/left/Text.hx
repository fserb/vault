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
  public var text: String;
  public var xoffset: Float;
  public var align: TextAlign;
  public var valign: TextVAlign;
  public var scale: Float;
  public var alpha: Float;

  static var repo_font: Map<String, BMFont>;

  var font: BMFont;

  public function new(fontname: String) {
    pos = Vec2.make(0, 0);
    xoffset = 0.0;
    align = LEFT;
    valign = TOP;
    scale = 1.0;
    alpha = 1.0;

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

  public function width(): Float {
    var dx = 0.0;
    for (i in 0...text.length) {
      var c: Char = cast font.chars[text.charCodeAt(i)];
      dx += c.xadvance + xoffset;
    }
    return dx*scale;
  }

  public function height(): Float {
    return font.lineHeight*scale;
  }

  override public function render(view: View) {
    var x = pos.x;
    var y = pos.y;

    switch (align) {
      case LEFT:
      case CENTER: x -= width()/2;
      case RIGHT: x -= width();
    }

    switch (valign) {
      case TOP:
      case MIDDLE: y -= height()/2;
      case BOTTOM: y -= height();
    }

    for (i in 0...text.length) {
      var c: Char = cast font.chars[text.charCodeAt(i)];
      view.draw(c.image, x, y, 0.0, scale, scale, alpha);
      x += (c.xadvance + xoffset)*scale;
    }
  }
}
