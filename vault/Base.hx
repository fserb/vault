package vault;

class Pair<T1, T2> {
  public var first(default, null):T1;
  public var second(default, null):T2;

  public function new(first:T1, second:T2) {
    this.first = first;
    this.second = second;
  }

  public function toString():String {
    return "(" + first + ", " + second + ")";
  }

  public static function compare<T1, T2>(one:Pair<T1, T2>, other:Pair<T1, T2>):Int {
    var c1 = Reflect.compare(one.first, other.first);
    if (c1 != 0) {
      return c1;
    }
    return Reflect.compare(one.second, other.second);
  }
}

class Base {
  static public function compareWithKey<T,C>(key:T -> C):T -> T -> Int {
    return function(a:T, b:T):Int {
      return Reflect.compare(key(a), key(b));
    };
  }
}
