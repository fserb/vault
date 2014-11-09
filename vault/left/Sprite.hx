package vault.left;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.display.Tilesheet;
import vault.EMath;
import vault.Vec2;

class Sprite extends Object {
  public var pos: Vec2;
  public var scaleX: Float = 1.0;
  public var scaleY: Float = 1.0;
  public var scale(get, set): Float;
  public var angle: Float = 0.0;
  public var alpha: Float = 1.0;

  public var image: Image = null;
  public var frame: Int = -1;

  public var globalpos: Bool = false;

  public function get_scale(): Float {
    return scaleX;
  }
  public function set_scale(v: Float): Float {
    scaleX = scaleY = v;
    return scaleX;
  }

  public function new() {
    pos = Vec2.make(0, 0);
  }

  override public function render(view: View) {
    if (image == null) return;
    var im = frame == -1 ? image : image[frame];

    var vp = globalpos? Vec2.make(0,0): view.pos;

    var acos = EMath.fabs(Math.cos(angle));
    var asin = EMath.fabs(Math.sin(angle));
    var w = im.height*asin + im.width*acos;
    var h = im.width*asin + im.height*acos;
    var x1 = pos.x - im.offset.x*w/im.width - vp.x;
    var y1 = pos.y - im.offset.y*h/im.height - vp.y;
    var x2 = x1 + w;
    var y2 = y1 + h;

    if (x1 < view.width && x2 > 0 && y1 < view.height && y2 > 0) {
      view.draw(im, pos.x - vp.x, pos.y - vp.y, angle, scaleX, scaleY, alpha);
    }
  }

  // using this (instead of Tilesheet) means Image.bitmap must be always valid
  // and we may have to account for subzone areas.
  // TODO: account for subzones.
  function imageBlit(width: Int, height: Int,
                     img: Image, x: Float, y: Float,
                     angle: Float, scaleX: Float, scaleY: Float): BitmapData {
    var sprite = new flash.display.Sprite();
    var mat = new Matrix();
    mat.translate(-img.width/2, -img.height/2);
    mat.scale(scaleX, scaleY);
    mat.rotate(-angle);
    mat.translate(x, y);
    sprite.graphics.beginBitmapFill(img.bitmap, mat, false, false);

    var p0 = mat.transformPoint(new Point(0, 0));
    var p1 = mat.transformPoint(new Point(img.width, 0));
    var p2 = mat.transformPoint(new Point(img.width, img.height));
    var p3 = mat.transformPoint(new Point(0, img.height));

    sprite.graphics.moveTo(p0.x, p0.y);
    sprite.graphics.lineTo(p1.x, p1.y);
    sprite.graphics.lineTo(p2.x, p2.y);
    sprite.graphics.lineTo(p3.x, p3.y);

    var bmd = new BitmapData(width, height, true, 0);
    bmd.draw(sprite);
    return bmd;
  }

  // returns true if colliding with @target. It does a pixel perfect collision.
  public function collide(target: Sprite): Bool {
    // 1. Big BB collision considering rotation
    var aDiag = Vec2.make(this.image.width/2, this.image.height/2).length;
    var aBB = new Rectangle(this.pos.x - aDiag, this.pos.y -aDiag, aDiag*2, aDiag*2);
    var bDiag = Vec2.make(target.image.width/2, target.image.height/2).length;
    var bBB = new Rectangle(target.pos.x - bDiag, target.pos.y -bDiag, bDiag*2, bDiag*2);

    var bigintersect = aBB.intersection(bBB);
    if (bigintersect.width <= 0) {
      return false;
    }

    var aimg = this.frame == -1 ? this.image : this.image[this.frame];
    var bimg = target.frame == -1 ? target.image : target.image[target.frame];

    // 2. Small BB collision considering rotation
    var acos = Math.cos(this.angle);
    var asin = Math.sin(this.angle);
    var bcos = Math.cos(target.angle);
    var bsin = Math.sin(target.angle);
    aBB.width = this.image.height*EMath.fabs(asin) + this.image.width*EMath.fabs(acos);
    aBB.height = this.image.width*EMath.fabs(asin) + this.image.height*EMath.fabs(acos);
    aBB.x = this.pos.x - aimg.offset.x*aBB.width/aimg.width;
    aBB.y = this.pos.y - aimg.offset.y*aBB.height/aimg.height;
    bBB.width = target.image.height*EMath.fabs(bsin) + target.image.width*EMath.fabs(bcos);
    bBB.height = target.image.width*EMath.fabs(bsin) + target.image.height*EMath.fabs(bcos);
    bBB.x = target.pos.x - bimg.offset.x*bBB.width/bimg.width;
    bBB.y = target.pos.y - bimg.offset.y*bBB.height/bimg.height;

    var intersect = aBB.intersection(bBB);
    if (intersect.width <= 0) {
      return false;
    }

    var width: Int = Std.int(Math.ceil(intersect.width));
    var height: Int = Std.int(Math.ceil(intersect.height));

    // 3. Pixel perfect collision
    var abmd = imageBlit(width, height, aimg, this.pos.x - intersect.x,
      this.pos.y - intersect.y, this.angle, this.scaleX, this.scaleY);

    var bbmd = imageBlit(width, height, bimg, target.pos.x - intersect.x,
      target.pos.y - intersect.y, target.angle, target.scaleX, this.scaleY);

    for (y in 0...height) {
      for (x in 0...width) {
        var a = abmd.getPixel32(x, y) & 0xFF000000;
        var b = bbmd.getPixel32(x, y) & 0xFF000000;
        if (a != 0 && b != 0) {
          return true;
        }
      }
    }
    return false;
  }
}
