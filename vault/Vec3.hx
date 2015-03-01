package vault;

class Vec3 {
  public var x: Float;
  public var y: Float;
  public var z: Float;
  public var length(get, set): Float;

  public function new (x:Float = 0, y:Float = 0, z:Float = 0) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public inline function set(x:Float, y:Float, z: Float) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public inline function get_length(): Float {
    return Math.sqrt(lsq());
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

  public inline function normalize(to: Float = 1.0): Vec3 {
    var d = length;
    if (d > 0) {
      var t = to/d;
      x *= t;
      y *= t;
      z *= t;
    }
    return this;
  }

  public inline function mul(scalar: Float) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
  }

  public inline function dot(b: Vec3): Float {
    return x*b.x + y*b.y + z*b.z;
  }

  public inline function copy(): Vec3 {
    return new Vec3(x, y, z);
  }

  public inline function equals(o: Vec3): Bool {
    return x == o.x && y == o.y && z == o.z;
  }

  public inline function toString(): String {
    return "Vec3(" + x + ", " + y + ", " + z + ")";
  }

  public inline function lsq(): Float {
    return x*x + y*y + z*z;
  }

  public inline function rotate(angle: Float) {
    var cs = Math.cos(angle);
    var sn = Math.sin(angle);
    var tmp = (x*cs - y*sn);
    y = (x*sn + y*cs);
    x = tmp;
  }

  public inline function add(b: Vec3) {
    x += b.x;
    y += b.y;
    z += b.z;
  }

  public inline function sub(b: Vec3) {
    x -= b.x;
    y -= b.y;
    z -= b.z;
  }

  public inline function cross(b: Vec3): Vec3 {
    return new Vec3(y*b.z - z*b.y, z*b.x - b.z*x, x*b.y - y*b.x);
  }

  public inline function distance(b: Vec3): Vec3 {
    return new Vec3(x - b.x, y - b.y, z - b.z);
  }

  public inline function anglebetween(b: Vec3): Float {
    return Math.acos(dot(b)/(this.length*b.length));
  }

  // Reflect @v in plane whose normal is @plane.
  // Both V and V' are pointing outwards: V' = 2N.(V.N) - V
  // For in/out: V' = V - 2N(VN)
  public inline function reflect(plane: Vec3) {
    var nn = plane.copy();
    nn.mul(2*dot(plane));
    x -= nn.x;
    y -= nn.y;
    z -= nn.x;
  }

  public inline function clamp(v: Float): Vec3 {
    var s = this.length;
    if (s > v) {
      mul(v/s);
    }
    return this;
  }

  public inline function project(a: Vec3): Vec3 {
    var dp = dot(a);
    var l = lsq();
    return new Vec3(dp / l * x, dp / l * y, dp / l * z);
  }
}
