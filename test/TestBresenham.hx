import vault.Point;
import vault.Line.Bresenham;
import vault.EMath;
import vault.Vec2;

class TestBresenham extends haxe.unit.TestCase {
  function P(x, y) { return new Point(x, y); }

  function assertArrayEquals(golden: Array<Point>, test: Bresenham): Bool {
    var i = 0;
    for (p in test) {
      if (golden[i].x != p.x || golden[i].y != p.y) {
        return false;
      }
      i++;
    }
    return i == golden.length;
  }

  public function testDiagonal() {
    assertTrue(assertArrayEquals([P(0,0), P(1,1), P(2,2), P(3,3), P(4,4), P(5,5)], new Bresenham(0, 0, 5, 5)));
    assertTrue(assertArrayEquals([P(0,0), P(1,0), P(2,0), P(3,0), P(4,0), P(5,0)], new Bresenham(0, 0, 5, 0)));
    assertTrue(assertArrayEquals([P(0,0), P(0,1), P(0,2), P(0,3), P(0,4), P(0,5)], new Bresenham(0, 0, 0, 5)));
    assertTrue(assertArrayEquals([P(5,5), P(4,4), P(3,3), P(2,2), P(1,1), P(0,0)], new Bresenham(5, 5, 0, 0)));
    assertTrue(assertArrayEquals([P(5,0), P(4,0), P(3,0), P(2,0), P(1,0), P(0,0)], new Bresenham(5, 0, 0, 0)));
    assertTrue(assertArrayEquals([P(0,5), P(0,4), P(0,3), P(0,2), P(0,1), P(0,0)], new Bresenham(0, 5, 0, 0)));
  }

  public function testBaseImplementation() {
    var dim = 5;
    var cnt = 0;
    for (x0 in -dim...dim+1) {
      for (y0 in -dim...dim+1) {
        for (x1 in -dim...dim+1) {
          for (y1 in -dim...dim+1) {
            var golden = new Vec2(x1 - x0, y1 - y0).angle;
            var i = 0;
            var last = null;
            for (p in new Bresenham(x0, y0, x1, y1)) {
              var angle = new Vec2(p.x - x0, p.y - y0).angle;
              var diff = Math.abs(EMath.angledistance(golden, angle));
              assertTrue(diff <= Math.PI/(i+1));
              if (i == 0) assertTrue(x0 == p.x && y0 == p.y);
              i++;
              last = p;
            }
            assertTrue(last.x == x1 && last.y == y1);
          }
        }
      }
    }
  }
}
