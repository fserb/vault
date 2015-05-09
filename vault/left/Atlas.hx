package vault.left;

import flash.geom.Point;
import flash.geom.Rectangle;
import vault.left.Image;
import flash.display.BitmapData;
import openfl.display.Tilesheet;

typedef Zone = {
  sheet: Int,
  x: Int,
  y: Int,
  w: Int,
  h: Int,
}

class Atlas {
  var bitmaps: Array<BitmapData>;
  var tilesheets: Array<Tilesheet>;
  var zones: Array<Zone>;

  var BORDER: Int = 2;
  static public var DIM: Int = 2048;

  public function new() {
    zones = new Array<Zone>();
    bitmaps = new Array<BitmapData>();
    tilesheets = new Array<Tilesheet>();
  }

  public function debug() {
    var b = new flash.display.Bitmap(bitmaps[0]);
    // b.scaleX = b.scaleY = 500/2048;
    b.scaleX = b.scaleY = 0.5;
    b.x = 5;
    b.y = -2048*b.scaleX+ 576 - 5;
    Left.game.addChild(b);
  }

  function drawRect(bmp: BitmapData, x: Int, y: Int, w: Int, h: Int, c: UInt) {
    bmp.fillRect(new Rectangle(x, y, 1, h), c);
    bmp.fillRect(new Rectangle(x+w-1, y, 1, h), c);
    bmp.fillRect(new Rectangle(x, y, w, 1), c);
    bmp.fillRect(new Rectangle(x, y+h-1, w, 1), c);
  }

  public function dumpAtlas() {
#if (!flash && !html5)
    for (i in 0...bitmaps.length) {
      var b = bitmaps[i];
      var bmp = new BitmapData(b.width, b.height, true, 0);
      bmp.copyPixels(b, b.rect, new Point(0, 0));

      var j = 0;
      for (z in zones) {
        if (z.sheet != i) continue;
        var c = 0xFF000000 | Std.int(0xFFFFFF*Math.random());
        drawRect(bmp, z.x+j, z.y+j, z.w-j*2, z.h-j*2, c);
        j++;
      }

      // Saving the BitmapData
      var ba = new flash.utils.ByteArray();
      bmp.encode(bmp.rect, "png", ba);
      var fo:sys.io.FileOutput = sys.io.File.write("atlas" + i + ".png", true);
      fo.writeString(ba.toString());
      fo.close();
    }
#end
  }

  function splitZone(free: Zone, used: Zone): Bool {
    if (used.x >= free.x + free.w || used.x + used.w <= free.x ||
        used.y >= free.y + free.h || used.y + used.h <= free.y) {
      return false;
    }

    if (used.x < free.x + free.w && used.x + used.w > free.x) {
      if (used.y > free.y && used.y < free.y + free.h) {
        zones.push({sheet: free.sheet, x: free.x, y: free.y, w: free.w, h: used.y - free.y});
      }
      if (used.y + used.h < free.y + free.h) {
        zones.push({sheet: free.sheet, x: free.x, y: used.y + used.h, w: free.w, h: free.y + free.h - (used.y + used.h)});
      }
    }
    if (used.y < free.y + free.h && used.y + used.h > free.y) {
      if (used.x > free.x && used.x < free.x + free.w) {
        zones.push({sheet: free.sheet, x: free.x, y: free.y, w: used.x - free.x, h: free.h});
      }
      if (used.x + used.w < free.x + free.w) {
        zones.push({sheet: free.sheet, x: used.x + used.w, y: free.y, w: free.x + free.w - (used.x + used.w), h: free.h});
      }
    }
    return true;
  }

  function getZone(width: Int, height: Int): Zone {
    // 1. see if we can fit it on an available zone
    var target: Zone = { sheet: -1, x: 0, y: 0, w: 0, h: 0 };
    var bestshort = EMath.MAX_INT;
    var bestlong = EMath.MAX_INT;
    var short: Int;
    var long: Int;
    for (z in zones) {
      // doesn't fit
      if (z.w < width || z.h < height) continue;
      var leftx = EMath.abs(z.w - width);
      var lefty = EMath.abs(z.h - height);
      if (leftx < lefty) {
        short = leftx;
        long = lefty;
      } else {
        short = lefty;
        long = leftx;
      }
      if (short < bestshort || (short == bestshort && long < bestlong)) {
        target.sheet = z.sheet;
        target.x = z.x;
        target.y = z.y + z.h - height;
        target.w = width;
        target.h = height;
        bestshort = short;
        bestlong = long;
      }
    }

    if (target.sheet == -1) {
      // 1b. otherwise, create a new zone and select it.
      var bmp = new BitmapData(DIM, DIM, true, 0);
      if (bmp == null) {
        trace("Failed to create Atlas");
        #if !html5
          Sys.exit(12);
        #end
        return null;
      }
      bitmaps.push(bmp);
      tilesheets.push(new Tilesheet(bmp));
      zones.push({sheet: tilesheets.length-1, x: 0, y: 0,
                  w: bmp.width, h: bmp.height});
      target = {sheet: tilesheets.length-1, x: 0, y: bmp.height - height,
                w: width, h: height};
    }

    // 3. split all current unused zones.
    var i = 0;
    var toprocess = zones.length;
    while (i < toprocess) {
      if (splitZone(zones[i], target)) {
        zones[i] = null;
      }
      i++;
    }
    // 4. cleanup redundant zones.
    for (a in zones) {
      if (a == null) continue;
      for (i in 0...zones.length) {
        var b = zones[i];
        if (a == b || b == null) continue;

        if ((b.x >= a.x) && (b.y >= a.y) &&
            (b.x + b.w <= a.x + a.w) && (b.y + b.h <= a.y + a.h)) {
          zones[i] = null;
        }
      }
    }
    zones = zones.filter(function (a) return a != null);
    return target;
  }

  // returns a new image with @bmd stored in an atlas.
  public function storeImage(bmd: BitmapData): Image_ {
    var im = new Image_();
    im.zone = getZone(bmd.width + 2*BORDER, bmd.height + 2*BORDER);
    im.zone.x += BORDER;
    im.zone.y += BORDER;
    im.zone.w -= 2*BORDER;
    im.zone.h -= 2*BORDER;
    im.width = bmd.width;
    im.height = bmd.height;
    im.tilesheet = tilesheets[im.zone.sheet];
    im.bitmap = bmd;
    im.offset.x = bmd.width/2;
    im.offset.y = bmd.height/2;
    im.tileid = im.tilesheet.addTileRect(
      new Rectangle(im.zone.x, im.zone.y, im.zone.w, im.zone.h),
      new Point(im.offset.x, im.offset.y));

    for (b in 0...BORDER) {
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(0, 0, bmd.width, 1), new Point(im.zone.x-1-b, im.zone.y-1-b));
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(0, 0, bmd.width, 1), new Point(im.zone.x+b, im.zone.y-1-b));
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(0, bmd.height-1, bmd.width, 1), new Point(im.zone.x-1-b, im.zone.y+bmd.height+b));
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(0, bmd.height-1, bmd.width, 1), new Point(im.zone.x+b, im.zone.y+bmd.height+b));

      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(0, 0, 1, bmd.height), new Point(im.zone.x-1-b, im.zone.y-1-b));
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(0, 0, 1, bmd.height), new Point(im.zone.x-1-b, im.zone.y+b));
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(bmd.width-1, 0, 1, bmd.height), new Point(im.zone.x+bmd.width+b, im.zone.y-1-b));
      bitmaps[im.zone.sheet].copyPixels(bmd, new Rectangle(bmd.width-1, 0, 1, bmd.height), new Point(im.zone.x+bmd.width+b, im.zone.y+1+b));
    }
    bitmaps[im.zone.sheet].copyPixels(bmd, bmd.rect, new Point(im.zone.x, im.zone.y));
    return im;
  }
}

