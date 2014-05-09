package vault.ugl;

import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import vault.Vec2;

enum HitType {
  Rect(x: Float, y: Float, w: Float, h: Float);
  Circle(x: Float, y: Float, r: Float);
  Polygon(p:Array<Vec2>);
}

enum Align {
  TOPLEFT;
  MIDDLE;
  MIDDLELEFT;
  BOTTOMRIGHT;
}

class Entity {
  static var layer = 10;
  public var pos: Vec2;
  public var angle: Float;
  public var vel: Vec2;
  public var ticks: Float;
  var acc: Vec2;
  var className: String;
  var alignment: Align;
  var hits: List<HitType>;
  public var dead: Bool = false;
  public var art(get, null): PixelArt;
  public var gfx(get, null): GraphicArt;

  public var sprite: Sprite;
  public var base_sprite(default, null): Sprite;
  public var deltasprite: Vec2;
  public var rotationcenter: Vec2;

  public function update() {}
  public var args: Array<Dynamic>;
  public function begin() {}

  function get_art(): PixelArt {
    art.disabled = false;
    return art;
  }

  function get_gfx(): GraphicArt {
    gfx.disabled = false;
    return gfx;
  }

  public function new(?a: Dynamic, ?b: Dynamic, ?c: Dynamic, ?d: Dynamic, ?e: Dynamic) {
    args = [];
    if (a != null) args.push(a);
    if (b != null) args.push(b);
    if (c != null) args.push(c);
    if (d != null) args.push(d);
    if (e != null) args.push(e);

    base_sprite = new Sprite();
    sprite = new Sprite();
    base_sprite.addChild(sprite);
    art = new PixelArt(sprite);
    gfx = new GraphicArt(sprite);
    pos = new Vec2(0, 0);
    vel = new Vec2(0, 0);
    acc = new Vec2(0, 0);
    alignment = MIDDLE;
    deltasprite = new Vec2(0, 0);
    ticks = 0;
    angle = 0.0;
    rotationcenter = null;

    hits = new List<HitType>();

    var cn = Type.getClassName(Type.getClass(this)).split(".");
    className = cn[cn.length - 1];
    var layer: Null<Int> = Reflect.field(Type.getClass(this), "layer");
    Game.group(className, layer == null ? 10 : layer).add(this);
    begin();
    _update_location();
  }

  public function clearHitBox() {
    hits.clear();
  }

  public function addHitBox(h: HitType) {
    hits.add(h);
  }

  function rectToArray(x, y, w, h): Array<Vec2> {
    var o = new Array<Vec2>();
    o.push(new Vec2(x, y));
    o.push(new Vec2(x, y + h));
    o.push(new Vec2(x + w, y + h));
    o.push(new Vec2(x + w, y));
    return o;
  }

  function hitCircleCircle(xa:Float, ya:Float, ra:Float, xb:Float, yb:Float, rb:Float): Bool {
    var v = new Vec2(xb - xa, yb - ya);
    return v.length <= (rb + ra);
  }

  function hitPolygonAxis(points: Array<Vec2>, ret: Array<Float>) {
    for (i in 0...points.length) {
      var a = points[i];
      var b = points[(i+1) % points.length];
      var v = new Vec2(b.x - a.x, b.y - a.y).normal();
      // we should be able to only use half circunference.
      ret.push(v.angle);
    }
  }

  function hitMinMaxProjectPolygon(points: Array<Vec2>, angle: Float): Vec2 {
    var ret = Vec2.make(Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY);

    var axis = Vec2.make(1, 0);
    axis.rotate(angle);

    for (p in points) {
      var r = axis.dot(p);
      ret.x = Math.min(ret.x, r);
      ret.y = Math.max(ret.y, r);
    }

    return ret;
  }

  function hitCirclePolygon(xa:Float, ya:Float, ra:Float, pb:Array<Vec2>): Bool {
    var pa = new Array<Vec2>();
    var c = Math.ceil(Math.max(10, 2*Math.PI*ra/32));
    for (i in 0...c) {
      pa.push(new Vec2(xa + ra*Math.cos(2*Math.PI*i/c),
                       ya + ra*Math.sin(2*Math.PI*i/c)));
    }
    return hitPolygonPolygon(pa, pb);
}

  public var debugHit = false;
  function hitPolygonPolygon(pa: Array<Vec2>, pb: Array<Vec2>): Bool {
    // Calculate all interesting axis.
    var axis = new Array<Float>();
    hitPolygonAxis(pa, axis);
    hitPolygonAxis(pb, axis);

    axis.sort(function (x, y) { return x > y ? 1 : x < y ? -1 : 0; });

    #if ugldebug
    if (debugHit) {
      var g = Game.debugsprite.graphics;
      g.clear();
      g.lineStyle(1, 0xFF0000, 1.0);
      g.moveTo(pa[0].x, pa[0].y);
      for (p in pa) {
        g.lineTo(p.x, p.y);
      }
      g.lineTo(pa[0].x, pa[0].y);
      g.lineStyle(1, 0x00FF00, 1.0);
      g.moveTo(pb[0].x, pb[0].y);
      for (p in pb) {
        g.lineTo(p.x, p.y);
      }
      g.lineTo(pb[0].x, pb[0].y);
      for (a in axis) {
        var v = Vec2.make(100, 0);
        v.rotate(a);
        g.lineStyle(2, 0x0000FF, 1.0);
        g.moveTo(Game.width/2, Game.height/2);
        g.lineTo(Game.width/2 + v.x, Game.height/2 + v.y);
      }
    }
    #end

    var lastangle = axis[0] - 1;
    for (angle in axis) {
      if (angle - lastangle < 1e-15) continue;
      lastangle = angle;

      var a = hitMinMaxProjectPolygon(pa, angle);
      var b = hitMinMaxProjectPolygon(pb, angle);

      #if ugldebug
      if (debugHit) {
        var g = Game.debugsprite.graphics;

        g.lineStyle(5, 0x00FFFF, 1.0);
        var v = Vec2.make(1, 0);
        v.rotate(angle);
        g.moveTo(Game.width/2 + v.x*a.x, Game.height/2 + v.y*a.x);
        g.lineTo(Game.width/2 + v.x*a.y, Game.height/2 + v.y*a.y);
        g.lineStyle(5, 0xFF00FF, 1.0);
        var v = Vec2.make(1, 0);
        v.rotate(angle);
        g.moveTo(Game.width/2 + v.x*b.x, Game.height/2 + v.y*b.x);
        g.lineTo(Game.width/2 + v.x*b.y, Game.height/2 + v.y*b.y);
      }
      #end

      // we found a non intersecting axis. There is no collision, we can leave.
      if (a.y < b.x || b.y < a.x) {
        return false;
      }
    }
    return true;
  }

  function hitRectRect(xa:Float, ya:Float, wa:Float, ha:Float, xb:Float, yb:Float, wb:Float, hb:Float): Bool {
    return !( (xb > (xa + wa)) || ((xb + wb) < xa) ||
              (yb > (ya + ha)) || ((yb + hb) < ya));
  }

  function isHit(a: HitType, b: HitType): Bool {
    switch(a) {
      case Circle(xa, ya, ra):
        switch(b) {
          case Circle(xb, yb, rb):
            return hitCircleCircle(xa, ya, ra, xb, yb, rb);
          case Polygon(pointsb):
            return hitCirclePolygon(xa, ya, ra, pointsb);
          case Rect(xb, yb, wb, hb):
            return hitCirclePolygon(xa, ya, ra, rectToArray(xb, yb, wb, hb));
        }
      case Polygon(pointsa):
        switch(b) {
          case Circle(xb, yb, rb):
            return hitCirclePolygon(xb, yb, rb, pointsa);
          case Polygon(pointsb):
            return hitPolygonPolygon(pointsa, pointsb);
          case Rect(xb, yb, wb, hb):
            return hitPolygonPolygon(pointsa, rectToArray(xb, yb, wb, hb));
        }
      case Rect(xa, ya, wa, ha):
        switch(b) {
          case Circle(xb, yb, rb):
            return hitCirclePolygon(xb, yb, rb, rectToArray(xa, ya, wa, ha));
          case Polygon(pointsb):
            return hitPolygonPolygon(pointsb, rectToArray(xa, ya, wa, ha));
          case Rect(xb, yb, wb, hb):
            return hitRectRect(xa, ya, wa, ha, xb, yb, wb, hb);
        }
    }
    return false;
  }

  inline function transformVec2(m: Matrix, x: Float, y: Float): Vec2 {
    var o = m.transformPoint(new Point(x, y));
    return Vec2.make(o.x, o.y);
  }

  function transformHit(m: Matrix, input: HitType): HitType {
    return switch (input) {
      case Circle(x, y, r):
        var p = m.transformPoint(new Point(x, y));
        Circle(p.x, p.y, m.a*r);
      case Polygon(points):
        var out = new Array<Vec2>();
        for (p in points) {
          out.push(transformVec2(m, p.x, p.y));
        }
        Polygon(out);
      case Rect(x, y, w, h):
        if (m.b == 0 && m.d == 0) {
          var a = transformVec2(m, x, y);
          var b = transformVec2(m, x+w, y+h);
          Rect(a.x, a.y, b.x - a.x, b.y - a.y);
        } else {
          var out = new Array<Vec2>();
          out.push(transformVec2(m, x, y));
          out.push(transformVec2(m, x, y + h));
          out.push(transformVec2(m, x + w, y + h));
          out.push(transformVec2(m, x + w, y));
          Polygon(out);
        }
    };
  }

  public function hitGroup(g: String): Dynamic {
    for (e in Game.get(g)) {
      if (hit(e)) {
        return e;
      }
    }
    return null;
  }

  public function hit(e: Entity): Bool {
    if (e == null) return false;
    if (dead || e.dead) return false;
    if (ticks <= 0.1) return false;
    for (a in hits) {
      for (b in e.hits) {
        if (isHit(transformHit(base_sprite.transform.matrix, a),
                  transformHit(e.base_sprite.transform.matrix, b))) {
          return true;
        }
       }
    }
    return false;
  }

  public function accelerate(a: Vec2) {
    acc.add(a);
  }

  public function remove() {
    dead = true;
  }

  public function _update() {
    ticks += Game.time;

    update();

    acc.mul(Game.time);
    pos.x += Game.time*(vel.x + acc.x/2);
    pos.y += Game.time*(vel.y + acc.y/2);
    vel.add(acc);
    acc.x = acc.y = 0;

    _update_location();
  }

  inline function _update_location() {
    var m = new Matrix();

    m.identity();
    if (rotationcenter == null) {
      m.translate(-sprite.width/2.0, -sprite.height/2.0);
    } else {
      m.translate(-rotationcenter.x, -rotationcenter.y);
    }
    m.rotate(angle);
    m.translate(pos.x + deltasprite.x, pos.y + deltasprite.y);
    if (rotationcenter == null) {
      m.translate(sprite.width/2.0, sprite.height/2.0);
    } else {
      m.translate(rotationcenter.x, rotationcenter.y);
    }
    switch(alignment) {
      case TOPLEFT:
      case MIDDLE: m.translate(-sprite.width/2.0, -sprite.height/2.0);
      case MIDDLELEFT: m.translate(0, -sprite.height/2.0);
      case BOTTOMRIGHT: m.translate(-sprite.width, -sprite.height);
    }
    base_sprite.transform.matrix = m;
  }
}
