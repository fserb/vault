package vault;

import flash.display.DisplayObjectContainer;

class Extra {
  static function sortByArray(obj: DisplayObjectContainer, order: Array<Int>) {
    var rev = new Array<Int>();
    for (i in 0...obj.numChildren) {
      rev.push(0);
    }
    for (i in 0...obj.numChildren) {
      rev[order[i]] = i;
    }
    for (i in 0...obj.numChildren) {
      var fromidx = i;
      var toidx = rev[i];
      obj.swapChildrenAt(fromidx, toidx);
      rev[toidx] = rev[fromidx];
      rev[fromidx] = fromidx;
    }
  }

  static public function sortChildrenByLayer(obj: DisplayObjectContainer) {
    var idxs = new Array<Int>();
    for (i in 0...obj.numChildren) {
      idxs.push(i);
    }
    idxs.sort(function(a, b) {
      var van: Null<Int> = Reflect.field(obj.getChildAt(a), 'layer');
      var vbn: Null<Int> = Reflect.field(obj.getChildAt(b), 'layer');
      var va: Int = van == null ? 0 : van;
      var vb: Int = vbn == null ? 0 : vbn;
      if (va < vb) return -1;
      if (va > vb) return 1;
      return 0;
    });
    sortByArray(obj, idxs);
  }

  static public function sortChildrenByClass(obj: DisplayObjectContainer,
      order: Array<String>) {
    var idxs = new Array<Int>();
    for (i in 0...obj.numChildren) {
      idxs.push(i);
    }
    idxs.sort(function(a, b) {
      var va:Int = order.indexOf(Type.getClassName(Type.getClass(obj.getChildAt(a))));
      var vb:Int = order.indexOf(Type.getClassName(Type.getClass(obj.getChildAt(b))));
      if (va < vb) return -1;
      if (va > vb) return 1;
      return 0;
    });
    sortByArray(obj, idxs);
  }
}
