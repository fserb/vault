import flash.geom.Matrix;
import vault.Vec2;

class TestVec2 extends haxe.unit.TestCase {
  public function testCreate() {
    var v = Vec2.make(0, 1);

    assertTrue(v.x == 0);
    assertTrue(v.y == 1);

    var v2 = v.copy();

    assertTrue(v2.x == 0);
    assertTrue(v2.y == 1);
  }

  public function testOperations() {
    assertTrue(Vec2.make(3, 4).length() == 5);
  }

  public function testMatrix() {
    var m = new Matrix();

    var v = Vec2.make(1, 0);

    m.translate(10, 10);

    v.transform(m);

    assertTrue(v.x == 11);
    assertTrue(v.y == 10);
  }

  public function testAngle() {
    for (i in -100...100) {
      for (j in -100...100) {
        if (i == 0 && j == 0) continue;
        var v = Vec2.make(i, j);
        v.normalize();
        var a = v.angle();

        var r = Vec2.make(1, 0);
        r.rotate(a);

        var d = Vec2.make(r.x - v.x, r.y - v.y);
        assertTrue(d.length() < 1e-15);
      }
    }
  }

}
