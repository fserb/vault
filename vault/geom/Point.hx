package vault.geom;

typedef Point_ = {
  var x: Int;
  var y: Int;
}

typedef PointDir_ = {>Point_,
  var angle: Float;
};

abstract Point(Point_) from Point_ to Point_ {
  public inline function new (x: Int, y:Int) {
    this = {x: x, y: y};
  }

  public var x(get,set):Int;
  inline function get_x() return this.x;
  inline function set_x(x:Int) return this.x = x;

  public var y(get,set):Int;
  inline function get_y() return this.y;
  inline function set_y(y:Int) return this.y = y;

  public var length(get, never): Float;
  public inline function get_length(): Float {
    return Math.sqrt(x*x + y*y);
  }

  public var angle(get, never): Float;
  public function get_angle(): Float {
    if (x == 0 && y == 0) {
      return 0.0;
    }
    return (2*Math.PI + Math.atan2(y, x)) % (2*Math.PI);
  }

  public inline function make(x:Int, y:Int): Point {
    return new Point(x, y);
  }

  public inline function copy(): Point {
    return new Point(x, y);
  }

  public inline function vec2(): Vec2 {
    return new Vec2(x, y);
  }

  public inline function add(b: Point) {
    x += b.x;
    y += b.y;
  }

  public inline function sub(b: Point) {
    x -= b.x;
    y -= b.y;
  }

  public inline function mul(i: Int) {
    x *= i;
    y *= i;
  }

  public inline function dot(b: Point): Float {
    return x*b.x + y*b.y;
  }

  public inline function distance(p: Point): Point {
    return new Point(x - p.x, y - p.y);
  }

  public inline function fromVec2(v: Vec2): Point {
    return new Point(Std.int(v.x), Std.int(v.y));
  }
}
