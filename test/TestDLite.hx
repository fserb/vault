import vault.algo.DLiteMap;

class TestDLite extends haxe.unit.TestCase {
  function getArray(dlm:DLiteMap) {
    return Lambda.array(Reflect.field(dlm, "array"));
  }
  function getPrio(dlm:DLiteMap) {
    return Lambda.array(Reflect.field(dlm, "open"));
  }

  function printG(dlm:DLiteMap) {
    var array = getArray(dlm);
    var s = "\n";
    for (y in 0...10) {
      for (x in 0...10) {
        if (array[x][y].g == DLiteMap.INF) {
          s += "-- ";
        } else if (array[x][y].g < 10) {
          s += " " + array[x][y].g + " ";
        } else {
          s += array[x][y].g + " ";
        }
      }
      s += "\n";
    }
    return s;
  }

  public function testBasic() {
    var d = new DLiteMap(10, 10, 9, 4);

    d.setCost(3, 0, -1);
    d.setCost(3, 1, -1);
    d.setCost(3, 2, -1);
    d.setCost(3, 3, -1);

    d.setCost(8, 3, -1);
    d.setCost(8, 4, -1);
    d.setCost(8, 5, -1);
    d.setCost(8, 6, -1);

    var target = d.getNextFrom(0, 0);
    assertTrue(target.first == 1 && target.second == 0);
    // trace("(0, 0) -> " + target);
    // trace(printG(d));

    target = d.getNextFrom(7, 5);
    assertTrue(target.first == 7 && target.second == 4);
    // trace("(7, 5) -> " + target);
    // trace(printG(d));

    d.setCost(8, 4, 1);
    d.setCost(8, 5, 1);

    target = d.getNextFrom(7, 5);
    assertTrue(target.first == 8 && target.second == 5);
    // trace("(7, 5) -> " + target);
    // trace(printG(d));

  }
}
