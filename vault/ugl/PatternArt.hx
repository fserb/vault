package vault.ugl;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import vault.EMath;
import vault.ugl.Color;
import vault.Utils;

class PatternArt {
  var sprite: Sprite;
  var width: Int;
  var height: Int;

  public function new(base: Sprite) {
    sprite = base;
  }

  public function gfx(): Graphics {
    return sprite.graphics;
  }

  public function clear(): PatternArt {
    sprite.graphics.clear();
    return this;
  }

  public function bg(c: UInt, width: Int, height: Int): PatternArt {
    sprite.graphics.clear();
    sprite.graphics.beginFill(c);
    sprite.graphics.drawRect(0, 0, width, height);
    sprite.graphics.endFill();
    this.width = width;
    this.height = height;
    return this;
  }

  public function gradient(from: UInt, to: UInt, angle: Float, width: Int, height: Int): PatternArt {
    sprite.graphics.clear();
    this.width = width;
    this.height = height;

    var swidth = Math.ceil(this.width*EMath.SQRT2);
    var sheight = Math.ceil(this.height*EMath.SQRT2);

    var vy = new Vec2(0, 1);
    vy.rotate(angle);

    var vx = new Vec2(swidth, 0);
    vx.rotate(angle);

    var x0 = (-sheight/2.0)*vy.x - vx.x/2.0 + 240;
    var y0 = (-sheight/2.0)*vy.y - vx.y/2.0 + 240;

    for (i in 0...sheight) {
      var b = new Vec2(x0 + vy.x*i, y0 + vy.y*i);

      var alpha = (i - this.height*(EMath.SQRT2 - 1.0)/2.0)/this.height;
      sprite.graphics.lineStyle(2, Color.lerp(from, to, alpha));
      sprite.graphics.moveTo(b.x, b.y);
      sprite.graphics.lineTo(b.x + vx.x, b.y + vx.y);
    }
    sprite.graphics.lineStyle();
    return this;
  }

  /**
   * Draws a border around the entity
   */
  public function border(highlight: UInt, lowlight: UInt, size: Float): PatternArt {
    sprite.graphics.beginFill(highlight);
    sprite.graphics.moveTo(0, this.height);
    sprite.graphics.lineTo(0, 0);
    sprite.graphics.lineTo(this.width, 0);
    sprite.graphics.lineTo(this.width - size, size);
    sprite.graphics.lineTo(size, size);
    sprite.graphics.lineTo(size, this.height - size);
    sprite.graphics.lineTo(0, this.height);

    sprite.graphics.beginFill(lowlight);
    sprite.graphics.moveTo(this.width, 0);
    sprite.graphics.lineTo(this.width, this.height);
    sprite.graphics.lineTo(0, this.height);
    sprite.graphics.lineTo(size, this.height - size);
    sprite.graphics.lineTo(this.width - size, this.height - size);
    sprite.graphics.lineTo(this.width - size, size);
    sprite.graphics.lineTo(this.width, 0);
    sprite.graphics.endFill();
    return this;
  }

  public function repeat(angle: Float, xspace: Float, yspace: Float, func: Graphics -> Float -> Float -> Void): PatternArt {
    var swidth = this.width*EMath.SQRT2;
    var sheight = this.height*EMath.SQRT2;

    var vx = new Vec2(1, 0);
    vx.rotate(angle);

    var vy = new Vec2(0, 1);
    vy.rotate(angle);

    var x0 = 240 - swidth/2.0*vx.x - sheight/2.0*vy.x;
    var y0 = 240 - swidth/2.0*vx.y - sheight/2.0*vy.y;

    var bx = Math.ceil(swidth/xspace);
    var by = Math.ceil(sheight/yspace);

    for (iy in 0...by) {
      for (ix in 0...bx) {
        var x = x0 + vx.x*ix*xspace + vy.x*iy*yspace;
        var y = y0 + vx.y*ix*xspace + vy.y*iy*yspace;
        func(sprite.graphics, x, y);
      }
    }
    return this;
  }

  public function stripe(color: UInt, angle: Float, width: Float, gap: Float, ?alpha: Float = 1.0, ?offset: Float = 0.0): PatternArt {
    sprite.graphics.beginFill(color, alpha);

    var swidth = this.width*EMath.SQRT2;
    var sheight = this.height*EMath.SQRT2;

    var bars = Math.ceil(swidth/(width + gap));

    var vx = new Vec2(1, 0);
    vx.rotate(angle);

    var vy = new Vec2(0, sheight);
    vy.rotate(angle);

    var x0 = (-swidth/2.0 + offset)*vx.x - vy.x/2.0 + 240;
    var y0 = (-swidth/2.0 + offset)*vx.y - vy.y/2.0 + 240;

    for (i in 0...bars) {
      var p = new Vec2(x0 + vx.x*i*(width + gap),
                       y0 + vx.y*i*(width + gap));
      sprite.graphics.moveTo(p.x, p.y);
      sprite.graphics.lineTo(p.x + vx.x*width, p.y + vx.y*width);
      sprite.graphics.lineTo(p.x + vx.x*width + vy.x, p.y + vx.y*width + vy.y);
      sprite.graphics.lineTo(p.x + vy.x, p.y + vy.y);
      sprite.graphics.lineTo(p.x, p.y);
    }
    sprite.graphics.endFill();
    return this;
  }

  public function noise(color: UInt, alpha: Float, ?size: Int = 1): PatternArt {
    var y = 0;
    while (y < this.height) {
      var x = 0;
      while (x < this.width) {
        sprite.graphics.beginFill(color, alpha*Math.random());
        sprite.graphics.drawRect(x, y, size, size);
        x += size;
      }
      y += size;
    }
    sprite.graphics.endFill();
    return this;
  }
}


