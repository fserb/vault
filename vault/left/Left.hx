package vault.left;

import vault.left.Console;
import vault.left.Game;
import vault.left.View;

@:allow(vault.left.Game)
class Left {
  static public var game(default, null): Game;

  static public var width(default, null): Int;
  static public var height(default, null): Int;

  static public var time: Float;
  static public var elapsed: Float;

  static public var views: Array<View>;

  static public var atlas: Atlas;

  static public var key: Key;
  static public var mouse: Mouse;

  static public var console: Console;

  static public var profile: Profile;
}