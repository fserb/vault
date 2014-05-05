package vault;

class Bresenham {
  var p: Point;
  var end: Point;
  var delta: Point;
  var error: Int;
  var ystep: Int;
  var xstep: Int;
  var more: Bool;

  public function new(x0: Int, y0: Int, x1: Int, y1: Int) {
    p = new Point(x0, y0);
    end = new Point(x1, y1);
    delta = new Point(EMath.abs(x1 - x0), EMath.abs(y1 - y0));
    xstep = x0 < x1 ? 1 : -1;
    ystep = y0 < y1 ? 1 : -1;
    error = delta.x - delta.y;
    more = true;
  }

  public function hasNext(): Bool {
    return more;
  }

  public function next(): Point {
    var ret = new Point(p.x, p.y);
    more = (ret.x != end.x || ret.y != end.y);
    var e2 = 2*error;
    if (e2 > -delta.y) {
      error -= delta.y;
      p.x += xstep;
    }
    if (e2 < delta.x) {
      error += delta.x;
      p.y += ystep;
    }
    return ret;
  }
}

