package vault.ugl;

import flash.events.KeyboardEvent;
import flash.Lib;
import vault.Utils;

class Key {
  var state: Array<Bool>;

  var up_: Button;
  var down_: Button;
  var left_: Button;
  var right_: Button;
  var b1_: Button;
  var b2_: Button;

  public var up(get, null): Bool;
  public var up_pressed(get, null): Bool;
  function get_up(): Bool { return up_.value; }
  function get_up_pressed(): Bool { return up_.just; }
  public var down(get, null): Bool;
  public var down_pressed(get, null): Bool;
  function get_down(): Bool { return down_.value; }
  function get_down_pressed(): Bool { return down_.just; }
  public var left(get, null): Bool;
  public var left_pressed(get, null): Bool;
  function get_left(): Bool { return left_.value; }
  function get_left_pressed(): Bool { return left_.just; }
  public var right(get, null): Bool;
  public var right_pressed(get, null): Bool;
  function get_right(): Bool { return right_.value; }
  function get_right_pressed(): Bool { return right_.just; }
  public var b1(get, null): Bool;
  public var b1_pressed(get, null): Bool;
  function get_b1(): Bool { return b1_.value; }
  function get_b1_pressed(): Bool { return b1_.just; }
  public var b2(get, null): Bool;
  public var b2_pressed(get, null): Bool;
  function get_b2(): Bool { return b2_.value; }
  function get_b2_pressed(): Bool { return b2_.just; }

  public function new() {
    state = Utils.initArray(256, false);

    up_ = new Button(function() { return state[0x26] || state[0x57]; });
    down_ = new Button(function() { return state[0x28] || state[0x53]; });
    left_ = new Button(function() { return state[0x25] || state[0x41]; });
    right_ = new Button(function() { return state[0x27] || state[0x44]; });
    b1_ = new Button(function() { return state[0x5a] || state[0xbe] || state[0x20] || state[0x0d]; });
    b2_ = new Button(function() { return state[0x58] || state[0xbf]; });

    Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
    Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onRelease);
  }

  function onPress(ev:KeyboardEvent) {
    state[ev.keyCode] = true;
  }

  function onRelease(ev:KeyboardEvent) {
    state[ev.keyCode] = false;
  }

  public function update() {
    up_.update();
    down_.update();
    left_.update();
    right_.update();
    b1_.update();
    b2_.update();
  }

}

class Button {
  public var value: Bool;
  public var just: Bool;
  var testFunc: Void -> Bool;
  public function new(testFunc) {
    this.testFunc = testFunc;
    this.value = false;
    this.just = false;
  }

  public function update() {
    if (testFunc()) {
      if (!just && !value) {
        just = true;
        value = true;
      } else {
        just = false;
        value = true;
      }
    } else {
      value = false;
      just = false;
    }
  }
}
