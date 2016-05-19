
package vault.ugl;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import vault.Utils;
import openfl.text.TextField;

enum FontAlign {
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

class GraphicArt {
  var sprite: Sprite;
  public var disabled: Bool = false;
  var cacheIndex: Int = -1;

  public function new(base: Sprite) {
    sprite = base;
  }

  public function gfx(): Graphics {
    return sprite.graphics;
  }

  public function clear(): GraphicArt {
    sprite.graphics.clear();
    disabled = false;
    cacheIndex = -1;
    return this;
  }

  public function size(w: Int, h: Int): GraphicArt {
    return this.line().fill(0x000000, 0.0).rect(0, 0, w, h).fill();
  }

  public function cache(idx: Int): GraphicArt {
    if (idx == cacheIndex) {
      disabled = true;
    } else {
      clear();
      cacheIndex = idx;
    }
    return this;
  }

  public function fill(c: Null<Int> = null, ?alpha: Float = 1.0): GraphicArt {
    if (disabled) return this;
    if (c == null) {
      sprite.graphics.endFill();
    } else {
      sprite.graphics.beginFill(c, alpha);
    }
    return this;
  }

  public function line(thickness: Null<Float> = null, ?c: UInt = 0, ?alpha: Float = 1.0): GraphicArt {
    if (disabled) return this;
    if (thickness == null) {
      sprite.graphics.lineStyle();
    } else {
      sprite.graphics.lineStyle(thickness, c, alpha);
    }
    return this;
  }

  public function rect(x: Float, y: Float, w: Float, h: Float, ?round: Float = 0.0): GraphicArt {
    if (disabled) return this;
    if (round == 0.0) {
      sprite.graphics.drawRect(x, y, w, h);
    } else {
      sprite.graphics.drawRoundRect(x, y, w, h, round);
    }
    return this;
  }

  public function circle(x: Float, y: Float, r: Float): GraphicArt {
    if (disabled) return this;
    sprite.graphics.drawCircle(x, y, r);
    return this;
  }

  public function arc(x:Float, y:Float, r1:Float, r2:Float, b:Float, e:Float): GraphicArt {
    at(x, y, r1, b, e, true);
    at(x, y, r2, e, b, false);
    return this;
  }

  public function text(x: Float, y: Float, text: String, color: UInt, ?size: Int = 1): GraphicArt {
    if (disabled) return this;
    x += 0.5;
    y += 0.5;
    var bmpd = Text.drawText(text, 0xFF000000 | color, size);
    var m = new Matrix();
    m.translate((x - bmpd.width/2), (y - bmpd.height/2));
    sprite.graphics.beginBitmapFill(bmpd, m, false, false);
    sprite.graphics.drawRect(x - bmpd.width/2, y - bmpd.height/2, bmpd.width, bmpd.height);
    return this;
  }

  public function font(x: Float, y: Float, text: String, color: UInt, size: Int, font: String, align: FontAlign): GraphicArt {
    if (disabled) return this;

    var tf = new TextField();
    tf.selectable = false;
    tf.multiline = true;
    tf.autoSize = openfl.text.TextFieldAutoSize.LEFT;

    tf.text = text;
    var f = new openfl.text.TextFormat();
    f.size = size;
    f.color = color;
    var ttf = openfl.Assets.getFont(font);
    f.font = ttf.fontName;
    f.kerning = true;
    tf.setTextFormat(f);

    var bmpd = new BitmapData(Math.ceil(tf.width), Math.ceil(tf.height), true, 0);
    bmpd.draw(tf);

    var px = switch(align) {
      case TOP_LEFT | MIDDLE_LEFT | BOTTOM_LEFT: x;
      case TOP_CENTER | MIDDLE_CENTER | BOTTOM_CENTER: x - bmpd.width/2.0;
      case TOP_RIGHT | MIDDLE_RIGHT | BOTTOM_RIGHT: x - bmpd.width;
    }
    var py = switch(align) {
      case TOP_LEFT | TOP_CENTER | TOP_RIGHT: y;
      case MIDDLE_LEFT | MIDDLE_CENTER | MIDDLE_RIGHT: y - bmpd.height/2.0;
      case BOTTOM_LEFT | BOTTOM_CENTER | BOTTOM_RIGHT: y - bmpd.height;
    }

    var m = new Matrix();
    m.translate(px, py);
    sprite.graphics.beginBitmapFill(bmpd, m, false, true);
    sprite.graphics.drawRect(px, py, bmpd.width, bmpd.height);

    return this;
  }

  public function mt(x: Float, y: Float): GraphicArt {
    if (disabled) return this;
    sprite.graphics.moveTo(x, y);
    return this;
  }

  public function lt(x: Float, y: Float): GraphicArt {
    if (disabled) return this;
    sprite.graphics.lineTo(x, y);
    return this;
  }

  public function at(x:Float, y:Float, r:Float, b:Float, e:Float, ?jump:Bool = false): GraphicArt {
    var segments = Math.ceil(Math.abs(e-b)/(Math.PI/4));
    var theta = -(e-b)/segments;
    var angle = -b;
    var ctrlRadius = r/Math.cos(theta/2);
    if (jump) {
      sprite.graphics.moveTo(x+Math.cos(angle)*r, y+Math.sin(angle)*r);
    } else {
      sprite.graphics.lineTo(x+Math.cos(angle)*r, y+Math.sin(angle)*r);
    }
    for (i in 0...segments) {
      angle += theta;
      var angleMid = angle-(theta/2);
      var cx = x+Math.cos(angleMid)*(ctrlRadius);
      var cy = y+Math.sin(angleMid)*(ctrlRadius);
      // calculate our end point
      var px = x+Math.cos(angle)*r;
      var py = y+Math.sin(angle)*r;
      // draw the circle segment
      sprite.graphics.curveTo(cx, cy, px, py);
    }
    return this;
  }
}
