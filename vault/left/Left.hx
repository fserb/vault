package vault.left;

import vault.left.Game;
import vault.left.View;

@:allow(vault.left.Game)
class Left {

  static public var game(default, null): Game;

  static public var width(default, null): Int;
  static public var height(default, null): Int;

  static public var elapsed: Float;

  static public var view: View;
}
