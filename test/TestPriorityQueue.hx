import vault.ds.PriorityQueue;
using Lambda;

class TestPriorityQueue extends haxe.unit.TestCase {
  function getArray<T, P>(pq:PriorityQueue<T, P>) {
    return Lambda.array(Reflect.field(Reflect.field(pq, "heap"), "array"));
  }

  public function testPush() {
    var pq = new PriorityQueue<String, Int>();

    pq.push("two", 2);
    pq.push("three", 3);
    pq.push("one", 1);

    var array = getArray(pq);
    assertTrue(array.exists(function f(a) return a.elem == "one"));
    assertTrue(array.exists(function f(a) return a.elem == "two"));
    assertTrue(array.exists(function f(a) return a.elem == "three"));
  }

  public function testPop() {
    var pq = new PriorityQueue<String, Int>();

    assertTrue(pq.empty());
    pq.push("one", 1);
    assertFalse(pq.empty());
    assertEquals("one", pq.pop());
    assertTrue(pq.empty());

    pq.push("one", 1);
    pq.push("two", 2);

    var array = getArray(pq);
    assertEquals(2, array.length);

    assertEquals("one", pq.peek());
    assertEquals("one", pq.pop());
  }

  public function testFindAndRemove() {
    var pq = new PriorityQueue<String, Int>();

    pq.push("two", 2);
    pq.push("three", 3);
    pq.push("one", 1);

    var idx = pq.find(function(x) return x == "one");
    assertEquals(0, idx);
    pq.remove(idx);
    var idx = pq.find(function(x) return x == "two");
    assertEquals(0, idx);
    pq.remove(idx);
    var idx = pq.find(function(x) return x == "three");
    assertEquals(0, idx);
    pq.remove(idx);

    assertTrue(pq.empty());
  }
}
