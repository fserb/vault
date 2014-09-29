package vault.left;

import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.display.Tilesheet;
import openfl.Assets;
import flash.display.BitmapData;

/*
Interface for all images that need to be render on a view
*/
@:allow(vault.left.Atlas)
@:allow(vault.left.Image)
class Image_ {
  public var tilesheet: Tilesheet = null;
  public var tileid: Int = -1;
  public var width: Int = 0;
  public var height: Int = 0;
  public var offset: Vec2;

  public var bitmap(default, null): BitmapData = null;
  public var tiles: Array<Image> = null;
  var zone: vault.left.Atlas.Zone = null;

  function new() {
    offset = Vec2.make(0, 0);
  }
}

@:forward
@:allow(vault.left.Atlas)
abstract Image(Image_) to Image_ from Image_ {
  function new(i) { this = i; }

  @:arrayAccess public function getsub(key:Int): Image {
    return this.tiles[key];
  }

  static public function create(bmd: BitmapData): Image {
    var im = Left.atlas.storeImage(bmd);
    return im;
  }

  static public function createTiled(bmd: BitmapData, width: Int, height: Int, centered: Bool = true): Image {
    var base = Left.atlas.storeImage(bmd);

    var tx = Std.int(bmd.width/width);
    var ty = Std.int(bmd.height/height);
    base.tiles = [];

    var center = new Point(width/2, height/2);
    for (y in 0...ty) {
      for (x in 0...tx) {
        var im = new Image_();
        im.width = width;
        im.height = height;
        im.bitmap = base.bitmap;
        im.tilesheet = base.tilesheet;
        im.tileid = im.tilesheet.addTileRect(new Rectangle(
          base.zone.x + x*width, base.zone.y + y*width,
          width, height), center);
        if (centered) {
          im.offset.x = width/2.0;
          im.offset.y = height/2.0;
        }
        base.tiles.push(im);
      }
    }

    // create new subimages with tiles.
    return base;
  }

  static public function createMutableBitmap(width: Int, height: Int): Image {
    var im = new Image_();
    im.width = width;
    im.height = height;
    im.offset.x = width/2.0;
    im.offset.y = height/2.0;
    im.bitmap = new BitmapData(width, height, true, 0);
    im.tilesheet = new Tilesheet(im.bitmap);
    im.tileid = im.tilesheet.addTileRect(im.bitmap.rect,
      new Point(im.bitmap.width/2, im.bitmap.height/2));
    return im;
  }
}

