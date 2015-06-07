package vault.left;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.display.Tilesheet;
import flash.display.Sprite;

typedef Image = {
  var tilesheet: Tilesheet;
  var tileid: Int;
  var width: Int;
  var height: Int;
  var offset: Vec2;
  var bitmap: BitmapData;
  var tiles: Array<Image>;
  var zone: vault.left.Atlas.Zone;
}

typedef DrawOrder = {
  tilesheet: Tilesheet,
  data: Array<Float>,
  next: DrawOrder,
}

class View extends Sprite {
  var atlas: Atlas;
  var bgalpha: Float = 1.0;
  var bgcolor: UInt = 0x000000;
  var vport: Vec2 = null;
  var draworder: DrawOrder;
  var nextdraw: DrawOrder;
  var sprite: Sprite;

  public function new() {
    super();
    sprite = this;
    atlas = new Atlas();
    draworder = nextdraw = {tilesheet: null, data: null, next: null};
  }

  public function viewport(width: Float, height: Float,
      bgcolor: UInt=0x000000, bgalpha: Float = 0.0, scale: Float = 1.0) {
    vport = new Vec2(width, height);
    this.bgcolor = bgcolor;
    this.bgalpha = bgalpha;
    this.scaleX = this.scaleY = scale;
    scrollRect = new Rectangle(0, 0, vport.x, vport.y);
  }

  public function newImage(): Image {
    return { tilesheet: null, tileid: -1, width: 0, height: 0,
        offset: new Vec2(0, 0), bitmap: null, tiles: [], zone: null };
  }

  public function createImage(bmd: BitmapData): Image {
    var im = newImage();
    atlas.storeImage(bmd, im);
    return im;
  }

  public function createTiled(bmd: BitmapData, width: Int, height: Int, centered: Bool = true): Image {
    var base:Image = newImage();
    var center = new Point(width/2, height/2);

    var tx = Std.int(bmd.width/width);
    var ty = Std.int(bmd.height/height);
    for (y in 0...ty) {
      for (x in 0...tx) {
        var b = new BitmapData(width, height);
        b.copyPixels(bmd, new Rectangle(x*width, y*height, width, height), new Point(0, 0));
        var im = createImage(b);
        if (!centered) {
          im.offset.x = 0;
          im.offset.y = 0;
        }
        base.tiles.push(im);
      }
    }
    return base;
  }

  public function draw(img: Image, x: Float, y: Float, ?angle: Float = 0.0,
      scaleX: Float = 1.0, scaleY: Float = 1.0, alpha: Float = 1.0) {
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);

    if (nextdraw.tilesheet != img.tilesheet) {
      nextdraw = nextdraw.next = { tilesheet: img.tilesheet, data: [], next: null };
    }

    var l = nextdraw.data.length;
    nextdraw.data[l++] = x - img.offset.x*scaleX + img.width/2.0*scaleX;
    nextdraw.data[l++] = y - img.offset.y*scaleY + img.height/2.0*scaleY;
    nextdraw.data[l++] = img.tileid;
    nextdraw.data[l++] = scaleX*cos;
    nextdraw.data[l++] = scaleX*-sin;
    nextdraw.data[l++] = scaleY*sin;
    nextdraw.data[l++] = scaleY*cos;
    nextdraw.data[l++] = alpha;
  }

  public function render() {
    sprite.graphics.clear();

    if (vport != null) {
    scrollRect = new Rectangle(0, 0, vport.x, vport.y);

      sprite.graphics.beginFill(bgcolor, bgalpha);
      sprite.graphics.drawRect(0, 0, vport.x, vport.y);
      sprite.graphics.endFill();
    }
    nextdraw = draworder.next;
    while (nextdraw != null) {
      nextdraw.tilesheet.drawTiles(sprite.graphics, nextdraw.data, true,
        Tilesheet.TILE_ALPHA | Tilesheet.TILE_TRANS_2x2);
      nextdraw = nextdraw.next;
    }
    draworder = nextdraw = {tilesheet: null, data: null, next: null};
  }
}
