package vault;

import vault.geom.Vec2;
import vault.geom.Tri2;

typedef Segment = {
  var a: Vec2;
  var b: Vec2;
}

class Sight {
  public var walls: Array<Segment>;
  var points: Array<Vec2>;

  public function new() {
    walls = [];
    points = [];
  }

  function addPoint(a: Vec2) {
    for (p in points) {
      if (p.x == a.x && p.y == a.y) return;
    }
    points.push(a);
  }

  public function addWall(a: Vec2, b: Vec2) {
    walls.push({a: a, b: b});
    addPoint(a);
    addPoint(b);
  }

  public function addRect(a: Vec2, b: Vec2) {
    var ab = new Vec2(a.x, b.y);
    var ba = new Vec2(b.x, a.y);
    addWall(a, ab);
    addWall(ab, b);
    addWall(b, ba);
    addWall(ba, a);
  }

  function castMinRay(from: Vec2, ray: Vec2): Float {
    var mint = -1.0;
    var valid = false;

    for (w in walls) {
      var seg = w.b.distance(w.a);
      var m = -seg.x * ray.y + ray.x * seg.y;
      if (m == 0) continue;

      var t = ( seg.x * (from.y - w.a.y) - seg.y * (from.x - w.a.x)) / m;
      if (t < 0) continue;
      if (valid && t >= mint) continue;

      var s = (-ray.y * (from.x - w.a.x) + ray.x * (from.y - w.a.y)) / m;
      if (s < 0 || s > 1) continue;

      mint = t;
      valid = true;
    }

    return mint;
  }

  public function castLOS(from: Vec2): Array<Tri2> {
    var rays = new Array<Vec2>();

    for (p in points) {
      for (d in [-0.00001, 0, 0.00001]) {
        var ray = p.distance(from);
        ray.angle += d;
        var r = castMinRay(from, ray);
        if (r >= 0.0) {
          ray.mul(r);
          rays.push(ray);
        }
      }
    }

    rays.sort(function (a:Vec2, b:Vec2) {
      var d = a.angle - b.angle;
      if (d > 0) return 1;
      if (d < 0) return -1;
      return 0;
    });

    // we first filter points that are too close to each other.
    var filtered = new Array<Vec2>();
    var prev: Vec2 = rays[rays.length-1];
    for (a in rays) {
      var d = prev.distance(a).length;
      if (d >= 1) {
        prev = a;
        filtered.push(a);
      }
    }
    var ret = new Array<Tri2>();

    for (i in 0...filtered.length-1) {
      var a = filtered[i].copy();
      a.add(from);
      var b = filtered[i+1].copy();
      b.add(from);
      var tri = new Tri2(from, a, b);
      // If the triangle area < 1, ignore it
      if (Math.abs(tri.getAreaSigned()) > 1) {
        ret.push(tri);
      }
    }
    var a = filtered[filtered.length-1].copy();
    a.add(from);
    var b = filtered[0].copy();
    b.add(from);
    var tri = new Tri2(from, a, b);
    if (Math.abs(tri.getAreaSigned()) > 1) {
      ret.push(tri);
    }

    return ret;
  }
}
