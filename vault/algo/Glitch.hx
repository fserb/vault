package vault.algo;

import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.utils.ByteArray;


class Glitch {
  static var addr = 0;
  static public function glitch(source: BitmapData, iterations: Int, quality: Int = 50, alpha: Bool = true): BitmapData {
    var jpg: ByteArray = source.encode("jpg", quality);
    // var header_length = getJPEGHeaderLength(jpg);
    var header_length = 611;
    addr = iterations;
    for (i in 0...iterations) {
      glitchJPEGBytes(jpg, header_length);
    }
    var bmp = BitmapData.loadFromBytes(jpg);
    if (bmp == null || bmp.width == 0 || bmp.height == 0) {
      return glitch(source, iterations, quality);
    }

    if (alpha) {
      var out = new BitmapData(source.width, source.height, true, 0);
      var src = source.getPixels(source.rect);
      var bm = bmp.getPixels(bmp.rect);
      var o = new ByteArray();
      src.position = bm.position = 0;
      while (src.position < src.length) {
        var s = src.readUnsignedInt();
        var b = bm.readUnsignedInt();
        o.writeUnsignedInt((s & 0xFF000000) | (b & 0xFFFFFF));
      }
      o.position = 0;
      out.setPixels(source.rect, o);
      trace("img: ", bmp.width, bmp.height);
      return out;
    } else {
      return bmp;
    }
  }

  static function glitchJPEGBytes(jpg: ByteArray, header: Int) {
    var index = header + Std.int((jpg.length - header - 5)*Math.random());
    index = vault.EMath.min(jpg.length - 5, index);
    trace(header, index, jpg.length);
    jpg.position = index;
    jpg.writeByte(Std.int(Math.random()*256));
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
