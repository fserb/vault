package vault.left;

import vault.left.Console;
import vault.left.Scene;
import flash.display.DisplayObject;

@:allow(vault.left.Scene)
class Left {
  static public var scene(default, null): Scene;

  static public var width(default, null): Int;
  static public var height(default, null): Int;

  static public var time(default, null): Float;
  static public var elapsed(default, null): Float;

  static public var key(default, null): Key;
  static public var mouse(default, null): Mouse;

  static public var console(default, null): Console;
  static public var profile(default, null): Profile;

  static public function setScene(scenefunc: Void->Scene) {
    if (Left.scene != null) {
      Left.scene.onDestroy();
    }
    Left.scene = scenefunc();
  }

  static public function add(obj: DisplayObject) {
    Left.scene.addChild(obj);
    Left.scene.sortChildren();
  }

  static public function remove(obj: DisplayObject) {
    Left.scene.removeChild(obj);
  }

  static public function get(name: String): Array<Dynamic> {
    return Left.scene.getClass(name);
  }

  static public function one(name: String): Dynamic {
    var g = Left.scene.getClass(name);
    return g.length > 0 ? g[0] : null;
  }
}
