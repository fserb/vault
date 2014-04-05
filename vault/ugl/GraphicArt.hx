package vault.ugl;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import vault.Utils;

class GraphicArt {
  var sprite: Sprite;
  public function new(base: Sprite) {
    sprite = base;
  }

  public function gfx(): Graphics {
    return sprite.graphics;
  }

  public function clear(): GraphicArt {
    sprite.graphics.clear();
    return this;
  }

  public function fill(c: Null<UInt> = null): GraphicArt {
    if (c == null) {
      sprite.graphics.endFill();
    } else {
      sprite.graphics.beginFill(c, 1.0);
    }
    return this;
  }

  public function line(thickness: Null<Float> = null, c: UInt): GraphicArt {
    sprite.graphics.lineStyle(thickness, c, 1.0);
    return this;
  }

  public function rect(x: Float, y: Float, w: Float, h: Float, ?round: Float = 0.0): GraphicArt {
    if (round == 0.0) {
      sprite.graphics.drawRect(x, y, w, h);
    } else {
      sprite.graphics.drawRoundRect(x, y, w, h, round);
    }
    return this;
  }

  public function circle(x: Float, y: Float, r: Float): GraphicArt {
    sprite.graphics.drawCircle(x, y, r);
    return this;
  }

  public function text(x: Float, y: Float, text: String, color: UInt, ?size: Int = 1): GraphicArt {
    x += 0.5;
    y += 0.5;
    var bmpd = Text.drawText(text, 0xFF000000 | color, size);
    var m = new Matrix();
    m.translate((x - bmpd.width/2), (y - bmpd.height/2));
    sprite.graphics.beginBitmapFill(bmpd, m, false, false);
    sprite.graphics.drawRect(x - bmpd.width/2, y - bmpd.height/2, bmpd.width, bmpd.height);
    return this;
  }

  public function mt(x: Float, y: Float): GraphicArt {
    sprite.graphics.moveTo(x, y);
    return this;
  }

  public function lt(x: Float, y: Float): GraphicArt {
    sprite.graphics.lineTo(x, y);
    return this;
  }
}


