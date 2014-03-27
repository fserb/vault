package vault.ds;

class Heap<T> {
  var array:Array<T>;
  var cmp:T -> T -> Int;

  public function new(comparator:T -> T -> Int=null) {
    array = new Array();
    if (comparator == null) {
      cmp = Reflect.compare;
    } else {
      cmp = comparator;
    }
  }

  inline function parent(i:Int):Int { return Std.int((i-1)/2); }
  inline function left(i:Int):Int { return (i*2)+1; }
  inline function right(i:Int):Int { return (i*2)+2; }

  public function push(k:T) {
    var new_index:Int = array.length;
    var parent_index:Int = parent(new_index);
    var tmp:T;

    array.push(k);

    while (new_index > 0 && cmp(k, array[parent_index]) < 0) {
      // swap array[new_index] and array[parent_index].
      tmp = array[new_index];
      array[new_index] = array[parent_index];
      array[parent_index] = tmp;

      // move up.
      new_index = parent_index;
      parent_index = parent(new_index);
    }
  }

  public function remove(index:Int):T {
    var res:T;

    if (array.length <= 0 || index < 0 || index >= array.length) {
      return null;
    }

    if (array.length == 1) {
      return array.pop();
    }

    var removed:T = array[index];

    // replace the element with the last element on the last level.
    array[index] = array.pop();

    // bubble-down.
    var current = index;
    while(true) {
      var best = current;
      var left_child = left(best);
      var right_child = right(best);
      if (left_child < array.length && cmp(array[left_child], array[best]) < 0) {
        best = left_child;
      }
      if (right_child < array.length && cmp(array[right_child], array[best]) < 0) {
        best = right_child;
      }
      if (best != current) {
        var tmp = array[best];
        array[best] = array[current];
        array[current] = tmp;
        current = best;
      } else {
        break;
      }
    }

    return removed;
  }

  public function pop():T {
    return remove(0);
  }

  public function find(test:T->Bool):Int {
    var i:Int = 0;
    for (e in array) {
      if (test(e)) {
        return i;
      }
      i++;
    }

    return -1;
  }

  public function peek():T {
    if (empty()) {
      return null;
    }
    return array[0];
  }

  public function empty():Bool {
    return (array.length == 0);
  }
}
