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
    var iarr:Float = 1.0 / (rad + rad + 1.0);
    for (i in 0...src.height) {
      var a = 0.0, r = 0.0, g = 0.0, b = 0.0;

      // initial window
      var s = src.getPixel32(0, i);
      a += (rad+1)*(0xFF & (s >> 24));
      var alpha:Float = (0xFF & (s >> 24))/0xFF;
      r += alpha*(rad+1)*(0xFF & (s >> 16));
      g += alpha*(rad+1)*(0xFF & (s >> 8));
      b += alpha*(rad+1)*(0xFF & (s));
      for (j in 0...rad) {
        var s = src.getPixel32(EMath.min(src.width-1, j), i);
        a += (0xFF & (s >> 24));
        var alpha:Float = (0xFF & (s >> 24))/0xFF;
        r += alpha*(0xFF & (s >> 16));
        g += alpha*(0xFF & (s >> 8));
        b += alpha*(0xFF & (s));
      }

      for (j in 0...src.width) {
        var prev = src.getPixel32(EMath.max(0, j-rad-1), i);
        var next = src.getPixel32(EMath.min(src.width-1, j+rad), i);
        a += (0xFF & (next >> 24)) - (0xFF & (prev >> 24));
        var palpha:Float = (0xFF & (prev >> 24))/0xFF;
        var nalpha:Float = (0xFF & (next >> 24))/0xFF;
        r += nalpha*(0xFF & (next >> 16)) - palpha*(0xFF & (prev >> 16));
        g += nalpha*(0xFF & (next >> 8))  - palpha*(0xFF & (prev >> 8));
        b += nalpha*(0xFF & (next))       - palpha*(0xFF & (prev));

        var v = 0;
        v |= (0xFF & Math.round(a*iarr)) << 24;
        var alpha:Float = (a*iarr)/0xFF;
        if (alpha != 0.0) {
          v |= (0xFF & Math.round(r*iarr/alpha)) << 16;
          v |= (0xFF & Math.round(g*iarr/alpha)) << 8;
          v |= (0xFF & Math.round(b*iarr/alpha));
        }
        dst.setPixel32(j, i, v);
      }
    }
  }

  function boxBlurT(src, dst, rad) {
    var iarr = 1 / (rad + rad + 1);
    for (j in 0...src.width) {
      var a = 0.0, r = 0.0, g = 0.0, b = 0.0;

      // initial window
      var s = src.getPixel32(j, 0);
      a += (rad+1)*(0xFF & (s >> 24));
      var alpha:Float = (0xFF & (s >> 24))/0xFF;
      r += alpha*(rad+1)*(0xFF & (s >> 16));
      g += alpha*(rad+1)*(0xFF & (s >> 8));
      b += alpha*(rad+1)*(0xFF & (s));
      for (i in 0...rad) {
        var s = src.getPixel32(j, EMath.min(src.height-1, i));
        a += (0xFF & (s >> 24));
        var alpha:Float = (0xFF & (s >> 24))/0xFF;
        r += alpha*(0xFF & (s >> 16));
        g += alpha*(0xFF & (s >> 8));
        b += alpha*(0xFF & (s));
      }

      for (i in 0...src.height) {
        var prev = src.getPixel32(j, EMath.max(0, i-rad-1));
        var next = src.getPixel32(j, EMath.min(src.height-1, i+rad));
        a += (0xFF & (next >> 24)) - (0xFF & (prev >> 24));
        var palpha:Float = (0xFF & (prev >> 24))/0xFF;
        var nalpha:Float = (0xFF & (next >> 24))/0xFF;
        r += nalpha*(0xFF & (next >> 16)) - palpha*(0xFF & (prev >> 16));
        g += nalpha*(0xFF & (next >> 8))  - palpha*(0xFF & (prev >> 8));
        b += nalpha*(0xFF & (next))       - palpha*(0xFF & (prev));

        var v = 0;
        v |= (0xFF & Math.round(a*iarr)) << 24;
        var alpha:Float = (a*iarr)/0xFF;
        if (alpha != 0.0) {
          v |= (0xFF & Math.round(r*iarr/alpha)) << 16;
          v |= (0xFF & Math.round(g*iarr/alpha)) << 8;
          v |= (0xFF & Math.round(b*iarr/alpha));
        }
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
    sprite.graphics.beginBitmapFill(dst, null, false, false);
    sprite.graphics.drawRect(0, 0, dst.width, dst.height);
  }

  public function glow(radius: Float) {
    var orig = new BitmapData(Std.int(sprite.width), Std.int(sprite.height),
      true, 0x00FFFFFF);
    orig.draw(sprite);

    var src = new BitmapData(Std.int(sprite.width), Std.int(sprite.height),
      true, 0x00FFFFFF);
    var b = orig.getPixels(orig.rect);
    b.position = 0;
    src.setPixels(orig.rect, b);

    var dst = new BitmapData(Std.int(sprite.width), Std.int(sprite.height),
      true, 0x00FFFFFF);

    var boxes = boxesForGauss(radius, 3);
    boxBlur(src, dst, Std.int((boxes[0] - 1)/2));
    boxBlur(dst, src, Std.int((boxes[1] - 1)/2));
    boxBlur(src, dst, Std.int((boxes[2] - 1)/2));

    sprite.graphics.clear();
    sprite.graphics.beginBitmapFill(dst, null, false, false);
    sprite.graphics.drawRect(0, 0, dst.width, dst.height);
    sprite.graphics.beginBitmapFill(orig);
    sprite.graphics.drawRect(0, 0, dst.width, dst.height);
  }
}
