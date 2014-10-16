package vault;

import vault.Vec2;

class Geom {
  static public function distanceLinePoint(a: Vec2, b: Vec2, p: Vec2): Float {
    var ab = b.distance(a);
    var u = ((p.x - a.x) * ab.x + (p.y - a.y) * ab.y) / ab.lsq();
    var pu = Vec2.make(a.x + u * ab.x - p.x, a.y + u * ab.y - p.y);
    return pu.length;
  }

  static public function distanceSegmentPoint(a: Vec2, b: Vec2, p: Vec2): Float {
    var ab = b.distance(a);
    var u = ((p.x - a.x) * ab.x + (p.y - a.y) * ab.y) / ab.lsq();
    u = Math.min(1.0, Math.max(0.0, u));
    var pu = Vec2.make(a.x + u * ab.x - p.x, a.y + u * ab.y - p.y);
    return pu.length;
  }

  static public function projectPointLine(a: Vec2, b: Vec2, p: Vec2): Float {
    var ab = b.distance(a);
    return ((p.x - a.x) * ab.x + (p.y - a.y) * ab.y) / ab.lsq();
  }

  static public function lineIntersection(a1: Vec2, b1: Vec2,
                                          a2: Vec2, b2: Vec2): Null<Vec2> {
    var s1 = b1.distance(a1);
    var s2 = b2.distance(a2);

    var s = (-s1.y * (a1.x - a2.x) + s1.x * (a1.y - a2.y)) / (-s2.x * s1.y + s1.x * s2.y);
    var t = ( s2.x * (a1.y - a2.y) - s2.y * (a1.x - a2.x)) / (-s2.x * s1.y + s1.x * s2.y);

    if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
      return Vec2.make(a1.x + t*s1.x, a1.y + t*s1.y);
    }
    return null;
  }

  static public function pointInsideTriangle(p: Vec2, p0: Vec2, p1: Vec2, p2: Vec2): Bool {
    var s = p0.y * p2.x - p0.x * p2.y + (p2.y - p0.y) * p.x + (p0.x - p2.x) * p.y;
    var t = p0.x * p1.y - p0.y * p1.x + (p0.y - p1.y) * p.x + (p1.x - p0.x) * p.y;

    if ((s < 0) != (t < 0)) {
      return false;
    }

    var A = -p1.y * p2.x + p0.y * (p2.x - p1.x) + p0.x * (p1.y - p2.y) + p1.x * p2.y;
    if (A < 0.0) {
      s = -s;
      t = -t;
      A = -A;
    }
    return s > 0 && t > 0 && (s + t) < A;
  }

  // returns -1 if if @p is to the left of @ab, 1 if to the right or 0 if straight
  static public function directionSegmentPoint(a: Vec2, b: Vec2, p: Vec2): Int {
    var v = (p.x - a.x)*(b.y - a.y) - (b.x - a.x)*(p.y - a.y);
    if (v < 0) return -1;
    if (v > 0) return 1;
    return 0;
  }
}