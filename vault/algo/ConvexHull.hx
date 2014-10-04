package vault.algo;

import vault.Vec2;
import vault.Geom;

class ConvexHull {
  static public function generate(points: Array<Vec2>) {
    var hull = new Array<Vec2>();
    // add leftmost node:
    hull.push(points[0]);
    for (p in points) {
      if (p.x < hull[0].x) {
        hull[0] = p;
      }
    }
    for (p in hull) {
      var q = p;
      for (r in points) {
        var t = Geom.directionSegmentPoint(p, q, r);
        if (t == 1 || (t == 0 && r.distance(p).length > q.distance(p).length)) {
          q = r;
        }
      }
      if (q != hull[0]) {
        hull.push(q);
      }
    }
    return hull;
  }
}
