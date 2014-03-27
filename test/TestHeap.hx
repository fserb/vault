import vault.ds.Heap;
import vault.Base;
using Lambda;

typedef KV = { k: String, v: Int };

class TestHeap extends haxe.unit.TestCase {
  function getArray<T>(h:Heap<T>): Array<T> {
    return Reflect.field(h, "array");
  }

  public function testPush() {
    var h = new Heap<KV>(Base.compareWithKey(function(x) return x.v));

    h.push({k:"two", v: 2});
    h.push({k:"three", v: 3});
    h.push({k:"one", v: 1});

    var array = getArray(h);

    assertTrue(array.exists(function f(a) return a.k == "one"));
    assertTrue(array.exists(function f(a) return a.k == "two"));
    assertTrue(array.exists(function f(a) return a.k == "three"));
  }

  public function testMorePush() {
    var h = new Heap<Float>();

    for (i in 0...1000) {
      h.push(Math.random());
    }

    var array = getArray(h);
    assertEquals(1000, array.length);

    var top = 0.0;
    for (i in 0...1000) {
      var n = h.pop();
      assertTrue(n >= top);
      top = n;
    }
  }

  public function testPop() {
    var h = new Heap<KV>(Base.compareWithKey(function(x) return x.v));

    assertTrue(h.empty());
    h.push({k:"one", v: 1});
    assertFalse(h.empty());
    var v = h.pop();
    assertTrue(h.empty());
    assertEquals("one", v.k);

    h.push({k:"two", v: 2});
    h.push({k:"one", v: 1});

    var array = getArray(h);
    assertEquals(2, array.length);

    var p = h.peek();
    assertEquals("one", p.k);
    var p2 = h.pop();
    assertEquals(p.k, p2.k);
  }

  public function testFindAndRemove() {
    var h = new Heap<KV>(Base.compareWithKey(function(x) return x.v));

    h.push({k:"two", v: 2});
    h.push({k:"three", v: 3});
    h.push({k:"one", v: 1});

    var idx = h.find(function(x) return x.k == "one");
    assertEquals(0, idx);
    h.remove(idx);
    var idx = h.find(function(x) return x.k == "two");
    assertEquals(0, idx);
    h.remove(idx);
    var idx = h.find(function(x) return x.k == "three");
    assertEquals(0, idx);
    h.remove(idx);

    assertTrue(h.empty());
  }
}
