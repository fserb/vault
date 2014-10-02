package vault.left;

import vault.EMath;

/*
  Tilemap usage:

  // 100x100 is the tilemap dimension in tiles.
  // data is linear array with tile values of size 100*100.
  var map = new Tilemap(data, 100, 100);
  // 20x20 is the tile size.
  map.image = Image.loadTiledBitmap("tiles.png", 20, 20);
*/
class Tilemap extends Object {
  public var pos: Vec2;
  public var image: Image;
  public var data: Array<Int>;
  public var width: Int;
  public var height: Int;
  public function new(data: Array<Int>, width: Int, height: Int, ?image: Image = null) {
    this.data = data;
    this.width = width;
    this.height = height;
    this.image = image;
    this.pos = Vec2.make(0, 0);
  }

  function drawcmd(view: View, x: Int, y: Int, dx: Int, dy: Int) {
    var d = data[x+y*width];
    if (d != 0) {
      view.draw(image[d], dx, dy);
    }
  }

  override public function render(view: View) {
    var w = image[0].width;
    var h = image[0].height;

    var startx = Std.int(Math.floor((view.pos.x - pos.x)/w));
    var starty = Std.int(Math.floor((view.pos.y - pos.y)/h));
    var endx = startx + Std.int(Math.ceil(view.width/w)) + 2;
    var endy = starty + Std.int(Math.ceil(view.height/h)) + 2;

    startx = EMath.max(0, startx);
    starty = EMath.max(0, starty);
    endx = EMath.min(this.width, endx);
    endy = EMath.min(this.height, endy);

    var posx = Std.int(Math.floor(pos.x + startx*w - view.pos.x));
    var posy = Std.int(Math.floor(pos.y + starty*h - view.pos.y));

    var dy = posy;
    for (y in starty...endy) {
      var dx = posx;
      for (x in startx...endx) {
        drawcmd(view, x, y, dx, dy);
        dx += w;
      }
      dy += h;
    }
  }
}
