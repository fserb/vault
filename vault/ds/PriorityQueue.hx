package vault.ds;

private typedef PrioElem<T,P> = { elem: T, prio: P };

class PriorityQueue<T,P> {
  var heap: Heap<PrioElem<T,P>>;

  public function new(comparator:P -> P -> Int=null) {
    var basecmp;
    if (comparator == null) {
      basecmp = Reflect.compare;
    } else {
      basecmp = comparator;
    }
    heap = new Heap<PrioElem<T,P>>(
      function(a, b) return basecmp(a.prio, b.prio));
  }

  public function push(k:T, p:P) {
    var pe: PrioElem<T,P> = { elem: k, prio: p };
    heap.add(pe);
  }

  public function remove(index:Int):T {
    var e = heap.remove(index);
    if (e != null) {
      return e.elem;
    }
    return null;
  }

  public function pop():T {
    return remove(0);
  }

  public function peek():T {
    if (heap.empty()) {
      return null;
    }
    return heap.top().elem;
  }

  public function peekPriority():P {
    if (heap.empty()) {
      return null;
    }
    return heap.top().prio;
  }

  public function empty() {
    return heap.empty();
  }

  public function find(test: T->Bool):Int {
    return heap.find(function(pe) return test(pe.elem));
  }
}
