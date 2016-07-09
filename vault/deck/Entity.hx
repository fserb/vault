package vault.deck;

import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import vault.geom.Vec2;
import flash.display.Bitmap;
import openfl.Assets;

enum Alignment {
  CENTER;
  TOPLEFT;
}

class Entity {
  public var className: String;

  public var layer: Float;
  public var pos: Vec2;
  public var angle: Float;
  public var rect: Rectangle;
  public var aabb: Rectangle;
  public var dead: Bool = false;
  public var sprite: Sprite;
  public var bitmap: Bitmap;
  public var touchable: Bool = false;

  var lastangle: Float;
  var lastrect: Rectangle;
  var lastpos: Vec2;
  public var _touch: Void->Void;

  public function new() {
    var cn = Type.getClassName(Type.getClass(this)).split(".");
    className = cn[cn.length - 1];

    layer = 0.0;
    pos = new Vec2(Game.width/2, Game.height/2);
    angle = 0.0;
    lastangle = -1.0;
    lastrect = new Rectangle(0, 0, 0, 0);
    rect = new Rectangle(0, 0, 0, 0);
    lastpos = pos.copy();

    sprite = new Sprite();
    aabb = new Rectangle();

    if (Reflect.getProperty(this, "touch") != null) {
      touchable = true;
      _touch = Reflect.getProperty(this, "touch");
    }
    Game.entities.push(this);
    Game.sprite.addChild(sprite);
  }

  public function loadImage(name, align: Alignment = null) {
    if (align == null) align = CENTER;

    if (bitmap != null) {
      sprite.removeChild(bitmap);
    }
    bitmap = new Bitmap(Assets.getBitmapData(name));
    sprite.addChild(bitmap);
    switch(align) {
      case CENTER:
        bitmap.x = rect.x = -bitmap.width/2.0;
        bitmap.y = rect.y = -bitmap.height/2.0;
      case TOPLEFT:
        bitmap.x = bitmap.y = rect.x = rect.y = 0;
    }
    rect.width = bitmap.width;
    rect.height = bitmap.height;
  }

  inline function _extend_aabb(m: Matrix, x: Float, y: Float) {
    var o = m.transformPoint(new Point(x, y));
    if (aabb.x > o.x) aabb.x = o.x;
    if (aabb.y > o.y) aabb.y = o.y;
    if (aabb.right < o.x) aabb.right = o.x;
    if (aabb.bottom < o.y) aabb.bottom = o.y;
  }

  inline function _update_aabb() {
    aabb.x = aabb.y = 1e99;
    aabb.bottom = aabb.right = -1e99;

    var m = new Matrix();
    m.rotate(angle);
    m.translate(pos.x, pos.y);

    _extend_aabb(m, rect.x, rect.y);
    _extend_aabb(m, rect.right, rect.y);
    _extend_aabb(m, rect.x, rect.bottom);
    _extend_aabb(m, rect.right, rect.bottom);
  }

  public function update() {}

  public function _update() {
    update();

    sprite.x = pos.x;
    sprite.y = pos.y;
    sprite.rotation = angle*180/Math.PI;

    if (angle != lastangle || lastrect.x != rect.x || lastrect.y != rect.y ||
        lastrect.width != rect.width || lastrect.height != rect.height) {
      lastangle = angle;
      lastrect.x = rect.x;
      lastrect.y = rect.y;
      lastrect.width = rect.width;
      lastrect.height = rect.height;
      lastpos.x = pos.x;
      lastpos.y = pos.y;
      _update_aabb();
    } else if (pos.x != lastpos.x || pos.y != lastpos.y) {
      aabb.x += pos.x - lastpos.x;
      aabb.y += pos.y - lastpos.y;
      lastpos.x = pos.x;
      lastpos.y = pos.y;
    }
  }
}
