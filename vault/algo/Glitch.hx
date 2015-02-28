package vault.algo;

import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.utils.ByteArray;
import openfl.display.BitmapDataChannel;


class Glitch {
  static var failedglitch = 0;

  static public function glitch(source: BitmapData, quality: Int = 50, alpha: Bool = true): BitmapData {
    return source;
    var jpg: ByteArray = source.encode("jpg", quality);
    // var header_length = getJPEGHeaderLength(jpg);
    var header_length = 611;

    var bmp: BitmapData = null;
    while(true) {
      var index = header_length + Std.int((jpg.length/2 - header_length - 5)*Math.random());
      index = vault.EMath.min(jpg.length - 5, index);
      jpg.position = index;
      var b = jpg.readByte();
      jpg.position = index;
      jpg.writeByte(Std.int(Math.random()*256));

      bmp = BitmapData.loadFromBytes(jpg);
      if (bmp == null || bmp.width == 0 || bmp.height == 0) {
        failedglitch++;
        vault.left.Left.console.one("Glitch.failed", failedglitch);
        jpg.position = index;
        jpg.writeByte(b);
      } else {
        break;
      }
    }

    if (alpha) {
      var out = new BitmapData(bmp.width, bmp.height, true, 0);
      out.copyPixels(bmp, bmp.rect, new flash.geom.Point(0, 0));
      out.copyChannel(source, source.rect, new flash.geom.Point(0,0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
      return out;
    } else {
      return bmp;
    }
  }

  static function getJPEGHeaderLength(jpg: ByteArray): Int {
    var res = 417;
    for (i in 0...jpg.length) {
      if (jpg[i] == 0xFF && jpg[i+1] == 0xDA) {
        res = i+2;
        break;
      }
    }
    trace(res);
    return res;
  }
}
