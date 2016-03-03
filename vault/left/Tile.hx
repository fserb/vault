package vault.left;

import vault.EMath;
import vault.ds.Map2D;
import flash.display.BitmapData;
import openfl.Assets;
import flash.geom.Rectangle;
import flash.geom.Point;

class Tile {
  public var bitmapdata(default, null): BitmapData;
  var cache: Array<BitmapData>;
  public var width: Int;
  public var height: Int;
  var cols: Int;

  public function new(name: String, w: Int, h: Int) {
    bitmapdata = Assets.getBitmapData(name);
    cache = new Array<BitmapData>();
    width = w;
    height = h;
    cols = Std.int(bitmapdata.width / width);
  }

  public function get(idx: Int): BitmapData {
    if (cache.length >= idx || cache[idx] == null) {
        var b = new BitmapData(width, height, true, 0);
        b.copyPixels(bitmapdata,
          new Rectangle((idx % cols)*width, Std.int(idx / cols)*height,
                        width, height), new Point(0, 0));
        cache[idx] = b;
    }
    return cache[idx];
  }
}
