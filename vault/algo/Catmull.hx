package vault.algo;

import vault.geom.Vec2;
import vault.EMath;

class Catmull {
  public var data: Array<Vec2>;
  public var wrap: Bool;

  public function new(data: Array<Vec2> = null, wrap: Bool = true) {
    this.data = data != null ? data : new Array<Vec2>();
    this.wrap = wrap;
  }

  public function get(t: Float): Vec2 {
    var r = Vec2.make(0, 0);

    if (!wrap) {
      t = EMath.clamp(t, 0, data.length-1);
    } else {
      while (t < 0) t += data.length;
      t %= data.length;
    }

    var i: Int = Std.int(t);
    var p0: Vec2 = i >= 1 ? data[i-1] : wrap ? data[data.length-1] : data[0];
    var p1: Vec2 = data[i];
    var i2: Int = i < data.length-1 ? i+1 : wrap ? 0 : i;
    var p2: Vec2 = data[i2];
    var p3: Vec2 = i2 < data.length-1 ? data[i2+1] : wrap ? data[0] : data[i2];

    t -= i;
    var t2 = t*t;
    var t3 = t2*t;

    r.x = 0.5 * ( (2 * p1.x) +
                  (-p0.x + p2.x) * t +
                  (2*p0.x - 5*p1.x +4*p2.x - p3.x) * t2 +
                  (-p0.x + 3*p1.x -3*p2.x + p3.x) * t3 );
    r.y = 0.5 * ( (2 * p1.y) +
                  (-p0.y + p2.y) * t +
                  (2*p0.y - 5*p1.y +4*p2.y - p3.y) * t2 +
                  (-p0.y + 3*p1.y -3*p2.y + p3.y) * t3 );

    return r;
  }
}
