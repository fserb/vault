package vault.geom;

import vault.geom.Vec2;
import flash.geom.Rectangle;

class Tri2 {
  public var a: Vec2;
  public var b: Vec2;
  public var c: Vec2;

  public function new(a:Vec2, b:Vec2, c:Vec2) {
    this.a = a;
    this.b = b;
    this.c = c;
  }

  public function translate(v: Vec2) {
    a.add(v);
    b.add(v);
    c.add(v);
  }

  public function scale(v: Float) {
    a.mul(v);
    b.mul(v);
    c.mul(v);
  }

  public function rotate(angle: Float) {
    a.rotate(angle);
    b.rotate(angle);
    c.rotate(angle);
  }

  public function isClockwise(): Bool {
    return getAreaSigned() < 0.0;
  }

  public function flipVertex() {
    var t = b;
    b = c;
    c = t;
  }

  public function getBoundRect(): Rectangle {
    var r = new Rectangle();
    r.x = Math.min(a.x, Math.min(b.x, c.x));
    r.width = Math.max(a.x, Math.max(b.x, c.x)) - r.x;
    r.y = Math.min(a.y, Math.min(b.y, c.y));
    r.height = Math.max(a.y, Math.max(b.y, c.y)) - r.y;
    return r;
  }

  public function distanceTo(v: Vec2): Float {
    return 0.0;
  }

  public function getAreaSigned(): Float {
    return (a.x * b.y - b.x * a.y + b.x * c.y - c.x * b.y +
            c.x * a.y - a.x * c.y)/2.0;
  }

  public function getCenter(): Vec2 {
    return new Vec2((a.x + b.x + c.x)/3.0, (a.y + b.y + c.y)/3.0);
  }

  public function isPointInside(p: Vec2): Bool {
    var s = a.y * c.x - a.x * c.y + (c.y - a.y) * p.x + (a.x - c.x) * p.y;
    var t = a.x * b.y - a.y * b.x + (a.y - b.y) * p.x + (b.x - a.x) * p.y;

    if ((s < 0) != (t < 0)) {
      return false;
    }

    var A = -b.y * c.x + a.y * (c.x - b.x) + a.x * (b.y - c.y) + b.x * c.y;
    if (A < 0.0) {
      s = -s;
      t = -t;
      A = -A;
    }
    return s > 0 && t > 0 && (s + t) < A;
  }
}
