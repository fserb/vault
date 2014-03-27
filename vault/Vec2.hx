package vault;

import flash.geom.Matrix;

typedef Vec2_ = {
  var x: Float;
  var y: Float;
}

typedef VecDir = {>Vec2_,
  var angle: Float;
}

abstract Vec2(Vec2_) from Vec2_ to Vec2_ {
  public inline function new (x: Float, y:Float) {
    this = {x: x, y: y};
  }

  public var x(get,set):Float;
  inline function get_x() return this.x;
  inline function set_x(x:Float) return this.x = x;

  public var y(get,set):Float;
  inline function get_y() return this.y;
  inline function set_y(y:Float) return this.y = y;

  public inline static function make(x: Float, y: Float) {
    return new Vec2(x, y);
  }

  public inline function copy(): Vec2 {
    return new Vec2(x, y);
  }

  public inline function toString() {
    return 'Vec2($x,$y)';
  }

  public inline function unit(): Vec2 {
    var p = copy();
    p.normalize();
    return p;
  }

  public inline function length(): Float {
    return Math.sqrt((x*x + y*y));
  }

  public function angle(): Float {
    if (x == 0 && y == 0) {
      return 0.0;
    }
    return Math.atan2(y, x);
  }

  public inline function lsq(): Float {
    return x*x + y*y;
  }

  public inline function set(o: Vec2) {
    x = o.x;
    y = o.y;
  }

  public inline function setxy(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public inline function setangle(angle:Float) {
    var l = length();
    x = l*Math.cos(angle);
    y = l*Math.sin(angle);
  }

  public inline function normalize() {
    var d = length();
    if (d != 0 && d != 1) {
      x /= d;
      y /= d;
    }
  }

  public inline function rotate(angle: Float) {
    var ax = Math.sin(angle);
    var ay = Math.cos(angle);
    var temp = (ay*x - ax*y);
    y = x*ax + y*ay;
    x = temp;
  }

  public inline function mul(scalar: Float) {
    x *= scalar;
    y *= scalar;
  }

  public inline function add(b: Vec2) {
    x += b.x;
    y += b.y;
  }

  public inline function sub(b: Vec2) {
    x -= b.x;
    y -= b.y;
  }

  public inline function dot(b: Vec2) {
    return x*b.x + y*b.y;
  }

  public inline function cross(b: Vec2): Float {
    return b.y*x - b.x*y;
  }

  public inline function distance(b: Vec2): Float {
    var xx = x - b.x;
    var yy = y - b.y;
    return Math.sqrt(xx*xx + yy*yy);
  }

  public inline function anglebetween(b: Vec2): Float {
    return Math.acos(dot(b)/(length()*b.length()));
  }

  // Reflect @v in plane whose normal is @plane.
  public inline function reflect(plane: Vec2) {
    var normal = unit();
    normal.mul(2*normal.dot(plane));
    sub(normal);
  }

  public inline function transform(m: Matrix) {
    x = x * m.a + y * m.c + m.tx;
    y = x * m.b + y * m.d + m.ty;
  }

  public inline function clamp(v: Float) {
    var s = length();
    if (s > v) {
      mul(v/s);
    }
  }

  public inline function project(a: Vec2): Vec2 {
    var dp = dot(a);
    var l = lsq();
    return Vec2.make(dp / l * x, dp / l * y);
  }

  public inline function normal(): Vec2 {
    return Vec2.make(-y, x);
  }

}
