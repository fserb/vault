package vault;

import vault.Vec2;

typedef WVec2 = {
  var x: Float;
  var y: Float;
  var w: Float;
};

class Ray {
  // based on http://www.cse.yorku.ca/~amana/research/grid.pdf
  static public function extend(from: Vec2, to: Vec2, tilesize: Int = 1, valid: Int -> Int -> Bool): Vec2 {
    // normalise the points
    var p1:Vec2 = Vec2.make(from.x/tilesize, from.y/tilesize);
    var p2:Vec2 = Vec2.make(to.x/tilesize, to.y/tilesize);

    if (Std.int(p1.x) == Std.int(p2.x) && Std.int(p1.y) == Std.int(p2.y)) {
      //since it doesn't cross any boundaries, there can't be a collision
      return to.copy();
    }

    //find out which direction to step, on each axis
    var stepX:Int = (p2.x > p1.x) ? 1 : -1;
    var stepY:Int = (p2.y > p1.y) ? 1 : -1;

    var rayDirection:Vec2 = p2.distance(p1);

    //find out how far to move on each axis for every whole integer step on the other
    var ratioX:Float = rayDirection.x / rayDirection.y;
    var ratioY:Float = rayDirection.y / rayDirection.x;

    var deltaY:Float = EMath.fabs(p2.x - p1.x);
    var deltaX:Float = EMath.fabs(p2.y - p1.y);

    //initialise the integer test coordinates with the coordinates of the starting tile, in tile space ( integer )
    //Note: using noralised version of p1
    var testX:Int = Std.int(p1.x);
    var testY:Int = Std.int(p1.y);

    //initialise the non-integer step, by advancing to the next tile boundary / ( whole integer of opposing axis )
    //if moving in positive direction, move to end of curent tile, otherwise the beginning
    var maxX:Float = deltaX * ( ( stepX > 0 ) ? ( 1.0 - (p1.x % 1) ) : (p1.x % 1) );
    var maxY:Float = deltaY * ( ( stepY > 0 ) ? ( 1.0 - (p1.y % 1) ) : (p1.y % 1) );

    var endTileX:Int = Std.int(p2.x);
    var endTileY:Int = Std.int(p2.y);

    var collisionPoint:Vec2 = Vec2.make(0, 0);

    while (testX != endTileX || testY != endTileY) {
      if (maxX < maxY) {
        maxX += deltaX;
        testX += stepX;

        if (!valid(testX, testY)) {
          collisionPoint.x = testX;
          if ( stepX < 0 ) collisionPoint.x += 1.0; //add one if going left
          collisionPoint.y = p1.y + ratioY * ( collisionPoint.x - p1.x);
          collisionPoint.x *= tilesize;//scale up
          collisionPoint.y *= tilesize;
          return collisionPoint;
        }
      } else {
        maxY += deltaY;
        testY += stepY;
        if (!valid( testX, testY )) {
          collisionPoint.y = testY;
          if ( stepY < 0 ) collisionPoint.y += 1.0; //add one if going up
          collisionPoint.x = p1.x + ratioX * ( collisionPoint.y - p1.y);
          collisionPoint.x *= tilesize;//scale up
          collisionPoint.y *= tilesize;
          return collisionPoint;
        }
      }
    }
    //no intersection found, just return end point:
    return to.copy();
  }
}

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

class Wu {
  var steep: Bool;
  var dx: Float;
  var dy: Float;
  var gradient: Float;
  var intery: Float;
  var buffer: List<WVec2>;
  var x: Float;
  var xpxl2: Float;

  public function new(a: Vec2, b: Vec2) {
    steep = Math.abs(b.y - a.y) > Math.abs(b.x - a.x);

    if (steep) {
      var t = a.x; a.x = a.y; a.y = t;
      var t = b.x; b.x = b.y; b.y = t;
    }
    if (a.x > b.x) {
      var t = a.x; a.x = b.x; b.x = t;
      var t = a.y; a.y = b.y; b.y = t;
    }

    dx = b.x - a.x;
    dy = b.y - a.y;
    gradient = dy / dx;

    buffer = new List<WVec2>();

    // 1st. endpoint.
    var xend = Math.round(a.x);
    var yend = a.y + gradient * (xend - a.x);
    var xgap = 1 - ((a.x + 0.5) % 1);
    var xpxl1 = xend;
    var ypxl1 = Math.floor(yend);
    if (steep) {
      buffer.add(vec(ypxl1, xpxl1, (xgap * (1 - yend%1))));
      buffer.add(vec(ypxl1 + 1, xpxl1, (xgap * (yend%1))));
    } else {
      buffer.add(vec(xpxl1, ypxl1, (xgap * (1 - yend%1))));
      buffer.add(vec(xpxl1, ypxl1 + 1, (xgap * (yend%1))));
    }
    intery = yend + gradient;

    // 2nd. endpoint.
    xend = Math.round(b.x);
    yend = b.y + gradient * (xend - b.x);
    xgap = (b.x + 0.5) % 1;
    xpxl2 = xend;
    var ypxl2 = Math.floor(yend);
    if (steep) {
      buffer.add(vec(ypxl2, xpxl2, (xgap * (1 - yend%1))));
      buffer.add(vec(ypxl2 + 1, xpxl2, (xgap * (yend%1))));
    } else {
      buffer.add(vec(xpxl2, ypxl2, (xgap * (1 - yend%1))));
      buffer.add(vec(xpxl2, ypxl2 + 1, (xgap * (yend%1))));
    }

    x = xpxl1 + 1;
  }

  public function hasNext(): Bool {
    return buffer.length > 0 || x <= xpxl2 - 1;
  }

  public function next(): WVec2 {
    if (buffer.length > 0) {
      return buffer.pop();
    }

    if (steep) {
      buffer.add(vec(Math.floor(intery), x, (1 - intery%1)));
      buffer.add(vec(Math.floor(intery) + 1, x, (intery%1)));
    } else {
      buffer.add(vec(x, Math.floor(intery), (1 - intery%1)));
      buffer.add(vec(x, Math.floor(intery) + 1, (intery%1)));
    }
    intery += gradient;
    x += 1;
    return buffer.pop();
  }

  function vec(x: Float, y: Float, w: Float): WVec2 {
    return {x: x, y: y, w: w};
  }
}
