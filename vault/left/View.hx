package vault.left;

import flash.display.Sprite;
import flash.geom.Rectangle;
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
class View extends Group {
  // world space coordinates of the View:
  public var pos: Vec2;
  public var width(default, set): Int;
  public var height(default, set): Int;

  public var sprite: Sprite;
  public var scale(default, set): Float = 1.0;
  public var zoom(default, set): Float = 1.0;

  public var draworder: DrawOrder;
  public var nextdraw: DrawOrder;

  public var bgalpha: Float = 1.0;
  public var bgcolor: UInt = 0x000000;

  public var flags: Int = Tilesheet.TILE_ALPHA | Tilesheet.TILE_TRANS_2x2;

  public function new(width:Int = 0, height:Int = 0) {
    super();
    pos = Vec2.make(0, 0);
    sprite = new Sprite();
    this.width = width == 0 ? Left.width : width;
    this.height = height == 0 ? Left.height : height;
    sprite.x = sprite.y = 0;
  }

  public function set_width(width: Int): Int {
    this.width = width;
    sprite.scrollRect = new Rectangle(0, 0, width, height);
    return width;
  }

  public function set_height(height: Int): Int {
    this.height = height;
    sprite.scrollRect = new Rectangle(0, 0, width, height);
    return height;
  }

  public function set_scale(f: Float): Float {
    sprite.scaleX = sprite.scaleY = scale = f;
    return scale;
  }

  public function set_zoom(f: Float): Float {
    width = Math.round(width*zoom/f);
    height = Math.round(height*zoom/f);
    scale = zoom = f;
    return zoom;
  }

  public function draw(img: Image, x: Float, y: Float, ?angle: Float = 0.0,
    scaleX: Float = 1.0, scaleY: Float = 1.0, alpha: Float = 1.0) {
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);

    if (nextdraw.tilesheet != img.tilesheet) {
      nextdraw = nextdraw.next = { tilesheet: img.tilesheet, data: [], next: null };
    }

    var l = nextdraw.data.length;
    nextdraw.data[l++] = x - img.offset.x + img.width/2.0;
    nextdraw.data[l++] = y - img.offset.y + img.height/2.0;
    nextdraw.data[l++] = img.tileid;
    nextdraw.data[l++] = scaleX*cos;
    nextdraw.data[l++] = scaleX*-sin;
    nextdraw.data[l++] = scaleY*sin;
    nextdraw.data[l++] = scaleY*cos;
    nextdraw.data[l++] = alpha;

    Left.profile.renderDraw++;
  }

  override public function render(scene: Group) {
    sprite.graphics.clear();
    if (bgalpha != 0.0) {
      sprite.graphics.beginFill(bgcolor, bgalpha);
      sprite.graphics.drawRect(0, 0, width, height);
      sprite.graphics.endFill();
    }
    draworder = nextdraw = {tilesheet: null, data: null, next: null};

    if (members.length != 0) {
      super.render(this);
    } else {
      scene.render(this);
    }

    nextdraw = draworder.next;
    while (nextdraw != null) {
      Left.profile.renderTiles++;
      nextdraw.tilesheet.drawTiles(sprite.graphics, nextdraw.data, true, flags);
      nextdraw = nextdraw.next;
    }
  }
}

typedef DrawOrder = {
  tilesheet: Tilesheet,
  data: Array<Float>,
  next: DrawOrder,
}
