import vault.Base;

private typedef Tp = { x: String, v: Int };
private typedef Tp2 = { x: Int, y: Int };

class TestBase extends haxe.unit.TestCase {
  public function testCompareWithKey() {
    var c = Base.compareWithKey(function(k) return k.v);

    var tp1: Tp = {x: "hello", v: 2};
    var tp2: Tp = {x: "yeah", v: 1};

    assertTrue(c(tp1, tp2) > 0);
    assertEquals(0, c(tp1, tp1));
    assertTrue(c(tp2, tp1) < 0);
  }

  public function testCompareWithKeyPair() {
    var c = Base.compareWithKey(function(k) return new Pair(k.x, k.y));

    var tp1: Tp2 = {x: 1, y: 2};
    var tp2: Tp2 = {x: 2, y: 0};
    var tp3: Tp2 = {x: 1, y: 0};

    assertTrue(c(tp1, tp2) < 0);
    assertTrue(c(tp3, tp2) < 0);
    assertTrue(c(tp3, tp1) < 0);
    assertEquals(0, c(tp1, tp1));
  }
}
