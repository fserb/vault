package vault;

import flash.geom.Matrix;
import vault.Vec2;

enum HitType {
  CIRCLE(x: Float, y: Float, r: Float);
  RECT(x: Float, y: Float, w: Float, h: Float);
  POLYGON(p: Array<Vec2>);
}

class Collider {
  public static function hit(ga: Array<HitType>, gb: Array<HitType>): Bool {
    for (ha in ga) {
      for (hb in gb) {
        if (isHit(ha, hb)) {
          return true;
        }
      }
    }
    return false;
  }

  public static function transform(orig: HitType, m: Matrix): HitType {
    return switch (orig) {
      case CIRCLE(x, y, r):
        var p = m.transformPoint(new Point(x, y));
        CIRCLE(p.x, p.y, m.a*r);
      case POLYGON(points):
        var out = new Array<Vec2>();
        for (p in points) {
          out.push(transformVec2(m, p.x, p.y));
        }
        POLYGON(out);
      case RECT(x, y, w, h):
        if (m.b == 0 && m.d == 0) {
          var a = transformVec2(m, x, y);
          var b = transformVec2(m, x+w, y+h);
          RECT(a.x, a.y, b.x - a.x, b.y - a.y);
        } else {
          var out = new Array<Vec2>();
          out.push(transformVec2(m, x, y));
          out.push(transformVec2(m, x, y + h));
          out.push(transformVec2(m, x + w, y + h));
          out.push(transformVec2(m, x + w, y));
          POLYGON(out);
        }
    };
  }

  function isHit(a: HitType, b: HitType): Bool {
    switch(a) {
      case CIRCLE(xa, ya, ra):
        switch(b) {
          case CIRCLE(xb, yb, rb):
            return hitCircleCircle(xa, ya, ra, xb, yb, rb);
          case POLYGON(pointsb):
            return hitCirclePolygon(xa, ya, ra, pointsb);
          case RECT(xb, yb, wb, hb):
            return hitCircleRect(xa, ya, ra, xb, yb, wb, hb);
        }
      case POLYGON(pointsa):
        switch(b) {
          case CIRCLE(xb, yb, rb):
            return hitCirclePolygon(xb, yb, rb, pointsa);
          case POLYGON(pointsb):
            return hitPolygonPolygon(pointsa, pointsb);
          case RECT(xb, yb, wb, hb):
            return hitPolygonPolygon(pointsa, rectToArray(xb, yb, wb, hb));
        }
      case RECT(xa, ya, wa, ha):
        switch(b) {
          case CIRCLE(xb, yb, rb):
            return  hitCircleRect(xb, yb, rb, xa, ya, wa, ha);
          case POLYGON(pointsb):
            return hitPolygonPolygon(pointsb, rectToArray(xa, ya, wa, ha));
          case RECT(xb, yb, wb, hb):
            return hitRectRect(xa, ya, wa, ha, xb, yb, wb, hb);
        }
    }
    return false;
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

  // untested :(
  function hitCircleRect(xa:Float, ya:Float, ra:Float, xb:Float, yb:Float, wb:Float, hb:Float): Bool {
    var dx = Math.abs(xa - xb) - wb/2;
    var dy = Math.abs(ya - yb) - hb/2;

    if (dx > ra) return false;
    if (dy > ra) return false;

    if (dx <= 0) return true;
    if (dy <= 0) return true;

    return (dx*dx + dy*dy) <= ra*ra;
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

  function hitPolygonPolygon(pa: Array<Vec2>, pb: Array<Vec2>): Bool {
    // Calculate all interesting axis.
    var axis = new Array<Float>();
    hitPolygonAxis(pa, axis);
    hitPolygonAxis(pb, axis);

    axis.sort(function (x, y) { return x > y ? 1 : x < y ? -1 : 0; });

    var lastangle = axis[0] - 1;
    for (angle in axis) {
      if (angle - lastangle < 1e-15) continue;
      lastangle = angle;

      var a = hitMinMaxProjectPolygon(pa, angle);
      var b = hitMinMaxProjectPolygon(pb, angle);

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

  inline function transformVec2(m: Matrix, x: Float, y: Float): Vec2 {
    var o = m.transformPoint(new Point(x, y));
    return Vec2.make(o.x, o.y);
  }
}
