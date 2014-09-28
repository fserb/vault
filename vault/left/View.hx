package vault.left;

import flash.display.Sprite;
import openfl.display.Tilesheet;
import vault.left.Group;
import vault.left.Image;
import vault.Vec2;

/*
A View represents a view into the object space where all objects will be drawn to.
Since it exists both on the world space and on the display space, it contains values
for both sites.
sprite values are display space.
pos, width, height are world space.
Its main tech point is the ability to execute rendering orders from Objects.
*/
class View {
  // world space coordinates of the View:
  public var pos: Vec2;
  public var width: Int;
  public var height: Int;

  public var sprite: Sprite;

  public var draworder: DrawOrder;
  public var nextdraw: DrawOrder;

  public var flags: Int = Tilesheet.TILE_ALPHA | Tilesheet.TILE_TRANS_2x2;

  public function new(width:Int = 0, height:Int = 0) {
    sprite = new Sprite();
    sprite.x = sprite.y = 0;
    pos = Vec2.make(0, 0);
    this.width = width;
    this.height = height;
  }

  public function draw(img: Image, x: Float, y: Float, ?angle: Float = 0.0,
    scale: Float = 1.0, alpha: Float = 1.0) {
    var cos = scale*Math.cos(angle);
    var sin = scale*Math.sin(angle);

    if (nextdraw.tilesheet != img.tilesheet) {
      nextdraw = nextdraw.next = { tilesheet: img.tilesheet, data: [], next: null };
    }

    var l = nextdraw.data.length;
    nextdraw.data[l++] = x;
    nextdraw.data[l++] = y;
    nextdraw.data[l++] = img.tileid;
    nextdraw.data[l++] = cos;
    nextdraw.data[l++] = -sin;
    nextdraw.data[l++] = sin;
    nextdraw.data[l++] = cos;
    nextdraw.data[l++] = alpha;
  }

  public function render(scene: Group) {
    sprite.graphics.clear();
    sprite.graphics.beginFill(0x000000, 1.0);
    sprite.graphics.drawRect(0, 0, width, height);
    sprite.graphics.endFill();
    draworder = nextdraw = {tilesheet: null, data: null, next: null};

    scene.draw(this);

    nextdraw = draworder.next;
    while (nextdraw != null) {
      nextdraw.tilesheet.drawTiles(sprite.graphics, nextdraw.data, false, flags);
      nextdraw = nextdraw.next;
    }
  }
}

typedef DrawOrder = {
  tilesheet: Tilesheet,
  data: Array<Float>,
  next: DrawOrder,
}
