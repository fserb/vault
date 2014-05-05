import TestImport;

class Run {
  static function main(){
    var r = new haxe.unit.TestRunner();

    // r.add(new TestBase());
    r.add(new TestHeap());
    r.add(new TestPriorityQueue());
    r.add(new TestVec2());
    r.add(new TestBresenham());
    // r.add(new TestDLite());

    r.run();
  }
}
