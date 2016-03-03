package vault.ds;

class Map2D<T> {
  var m: Map<Int, Map<Int, T>>;

  public function new() {
    m = new Map<Int, Map<Int, T>>();
  }

  inline public function exists(x: Int, y: Int): Bool {
    if (!m.exists(x)) return false;
    if (!m.get(x).exists(y)) return false;
    return true;
  }

  inline public function get(x: Int, y: Int): Null<T> {
    if (!m.exists(x)) return null;
    return m.get(x).get(y);
  }

  inline public function set(x: Int, y: Int, v: T) {
    if (!m.exists(x)) m.set(x, new Map<Int, T>());
    m.get(x).set(y, v);
  }
}
