package vault.ugl;

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import vault.Utils;
import flash.utils.ByteArray;

class EffectArt {
  var sprite: Sprite;
  public function new(base: Sprite) {
    sprite = base;
  }

  function boxesForGauss(sigma:Float, n: Int): Array<Int> {
    var wIdeal = Math.sqrt((12*sigma*sigma/n)+1);
    var wl = Math.floor(wIdeal);
    if (wl % 2 == 0) wl--;
    var wu = wl+2;

    var m = Math.round((12*sigma*sigma - n*wl*wl - 4*n*wl - 3*n)/(-4*wl - 4));

    var sizes = [];
    for (i in 0...n) {
      sizes.push(i < m ? wl : wu);
    }
    return sizes;
  }

  function boxBlurH(src, dst, rad) {
    var h = src.height;
    var w = src.width;
    for (i in 0...h) {
      for (j in 0...w) {
        var a =0.0, r = 0.0, g = 0.0, b = 0.0;
        for (ix in (j-rad...j+rad+1)) {
          var x = EMath.min(w-1, EMath.max(0, ix));
          var s = src.getPixel32(x, i);
          a += (s & 0xFF000000) >> 24;
          r += (s & 0x00FF0000) >> 16;
          g += (s & 0x0000FF00) >> 8;
          b += (s & 0x000000FF);
        }
        var v = 0;
        var w = (rad+rad+1);
        v += (0xFF & Math.round(a/w)) << 24;
        v += (0xFF & Math.round(r/w)) << 16;
        v += (0xFF & Math.round(g/w)) << 8;
        v += (0xFF & Math.round(b/w));
        dst.setPixel32(j, i, v);
      }
    }
  }

  function boxBlurT(src, dst, rad) {
    var h = src.height;
    var w = src.width;
    for (i in 0...h) {
      for (j in 0...w) {
        var a =0.0, r = 0.0, g = 0.0, b = 0.0;
        for (iy in (i-rad...i+rad+1)) {
          var y = EMath.min(h-1, EMath.max(0, iy));
          var s = src.getPixel32(j, y);
          a += (s & 0xFF000000) >> 24;
          r += (s & 0x00FF0000) >> 16;
          g += (s & 0x0000FF00) >> 8;
          b += (s & 0x000000FF);
        }
        var v = 0;
        var w = (rad+rad+1);
        v += (0xFF & Math.round(a/w)) << 24;
        v += (0xFF & Math.round(r/w)) << 16;
        v += (0xFF & Math.round(g/w)) << 8;
        v += (0xFF & Math.round(b/w));
        dst.setPixel32(j, i, v);
      }
    }
  }

  function boxBlur(src:BitmapData, dst:BitmapData, rad:Int) {
    var b = src.getPixels(src.rect);
    b.position = 0;
    dst.setPixels(src.rect, b);
    boxBlurH(dst, src, rad);
    boxBlurT(src, dst, rad);
  }

  public function blur(radius: Float) {
    var src = new BitmapData(Std.int(sprite.width), Std.int(sprite.height),
      true, 0x00FFFFFF);
    src.draw(sprite);

    var dst = new BitmapData(Std.int(sprite.width), Std.int(sprite.height),
      true, 0x00FFFFFF);

    var boxes = boxesForGauss(radius, 3);
    boxBlur(src, dst, Std.int((boxes[0] - 1)/2));
    boxBlur(dst, src, Std.int((boxes[1] - 1)/2));
    boxBlur(src, dst, Std.int((boxes[2] - 1)/2));

    sprite.graphics.clear();
    sprite.graphics.beginBitmapFill(dst);
    sprite.graphics.drawRect(0, 0, dst.width, dst.height);
  }
}
