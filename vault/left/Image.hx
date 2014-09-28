package vault.left;

import flash.geom.Point;
import openfl.display.Tilesheet;
import openfl.Assets;
import flash.display.BitmapData;

/*
Interface for all images that need to be render on a view
*/
class Image {
  public var tilesheet: Tilesheet = null;
  public var tileid: Int = -1;

  public var bitmap(default, null): BitmapData = null;
  var tiles: Array<Image> = null;
  var tileoffset: Int = 0;

  function new() {
  }

  static public function loadImage(filename: String): Image {
    return loadBitmapData(Assets.getBitmapData(filename));
  }

  static public function loadBitmapData(bmd: BitmapData): Image {
    var im = new Image();
    im.bitmap = bmd;
    im.tilesheet = new Tilesheet(bmd);
    im.tileid = im.tilesheet.addTileRect(bmd.rect, new Point(bmd.width/2, bmd.height/2));
    return im;
  }

  static public function loadTiled(filename: String, width: Int, height: Int): Image {
    return null;
  }

  static public function createMutableBitmap(): Image {
    return null;
  }

}
