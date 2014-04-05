package vault;

import flash.geom.Matrix;

class Vec2 {
  public var x: Float;
  public var y: Float;
  public var length(get, set): Float;
  public var angle(get, set): Float;

  public function new (x:Float = 0, y:Float = 0) {
    this.x = x;
    this.y = y;
  }

  public inline static function make(x: Float, y: Float) {
    return new Vec2(x, y);
  }

  public inline function set(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public inline function get_length(): Float {
    return Math.sqrt(x*x + y*y);
  }

  public inline function set_length(v: Float): Float {
    var l = length;
    if (l == 0) {
      x = v;
    } else {
      mul(v/l);
    }
    return v;
  }

  public function get_angle(): Float {
    if (x == 0 && y == 0) {
      return 0.0;
    }
    return (2*Math.PI + Math.atan2(y, x)) % (2*Math.PI);
  }

  public function set_angle(v: Float): Float {
    var l = this.length;
    x = l*Math.cos(v);
    y = l*Math.sin(v);
    return v;
  }

  public inline function normalize() {
    var d = length;
    x /= d;
    y /= d;
  }

  public inline function mul(scalar: Float) {
    x *= scalar;
    y *= scalar;
  }

  public inline function dot(b: Vec2): Float {
    return x*b.x + y*b.y;
  }

  public inline function copy(): Vec2 {
    return new Vec2(x, y);
  }

  public inline function equals(o: Vec2): Bool {
    return x == o.x && y == o.y;
  }

  public inline function toString(): String {
    return "Vec2(" + x + "," + y + ")";
  }

  public inline function lsq(): Float {
    return x*x + y*y;
  }

  public inline function rotate(angle: Float) {
    var ax = Math.sin(angle);
    var ay = Math.cos(angle);
    var temp = (ay*x - ax*y);
    y = x*ax + y*ay;
    x = temp;
  }

  public inline function add(b: Vec2) {
    x += b.x;
    y += b.y;
  }

  public inline function sub(b: Vec2) {
    x -= b.x;
    y -= b.y;
  }

  public inline function cross(b: Vec2): Float {
    return b.y*x - b.x*y;
  }

  public inline function distance(b: Vec2): Vec2 {
    return new Vec2(x - b.x, y - b.y);
  }

  public inline function anglebetween(b: Vec2): Float {
    return Math.acos(dot(b)/(this.length*b.length));
  }

  // Reflect @v in plane whose normal is @plane.
  public inline function reflect(plane: Vec2) {
    var normal = copy();
    normal.normalize();
    normal.mul(2*normal.dot(plane));
    sub(normal);
  }

  public inline function transform(m: Matrix) {
    x = x * m.a + y * m.c + m.tx;
    y = x * m.b + y * m.d + m.ty;
  }

  public inline function clamp(v: Float) {
    var s = this.length;
    if (s > v) {
      mul(v/s);
    }
  }

  public inline function project(a: Vec2): Vec2 {
    var dp = dot(a);
    var l = lsq();
    return new Vec2(dp / l * x, dp / l * y);
  }

  public inline function normal(): Vec2 {
    return new Vec2(-y, x);
  }
}
