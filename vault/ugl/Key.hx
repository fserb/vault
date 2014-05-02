package vault.ugl;

import flash.events.KeyboardEvent;
import flash.Lib;
import vault.Utils;
import flash.external.ExternalInterface;

class Key {
  var state: Array<Bool>;

  var up_: Button;
  var down_: Button;
  var left_: Button;
  var right_: Button;
  var b1_: Button;
  var b2_: Button;
  var esc_: Button;
  var pause_: Button;
  var mute_: Button;
  var any_: Button;

  var joyEps = 0.5;
  var joyX = 0.0;
  var joyY = 0.0;
  var joyB1 = false;
  var joyB2 = false;

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
  public var esc(get, null): Bool;
  public var esc_pressed(get, null): Bool;
  function get_esc(): Bool { return esc_.value; }
  function get_esc_pressed(): Bool { return esc_.just; }
  public var any(get, null): Bool;
  public var any_pressed(get, null): Bool;
  function get_any(): Bool { return any_.value; }
  function get_any_pressed(): Bool { return any_.just; }
  public var mute(get, null): Bool;
  public var mute_pressed(get, null): Bool;
  function get_mute(): Bool { return mute_.value; }
  function get_mute_pressed(): Bool { return mute_.just; }
  public var pause(get, null): Bool;
  public var pause_pressed(get, null): Bool;
  function get_pause(): Bool { return pause_.value; }
  function get_pause_pressed(): Bool { return pause_.just; }

  public function new() {
    state = Utils.initArray(256, false);

    up_ = new Button(function() { return state[0x26] || state[0x57] || joyY < 0; });
    down_ = new Button(function() { return state[0x28] || state[0x53] || joyY > 0; });
    left_ = new Button(function() { return state[0x25] || state[0x41] || joyX < 0; });
    right_ = new Button(function() { return state[0x27] || state[0x44] || joyX > 0; });
    b1_ = new Button(function() { return joyB1 || state[0x58] || state[0xbe] || state[0x20] || state[0x0d]; });
    b2_ = new Button(function() { return joyB2 || state[0x5a] || state[0xbf]; });
    esc_ = new Button(function() { return state[0x1b]; });
    pause_ = new Button(function() { return state[0x50]; });
    any_ = new Button(function() {
      return up_.value || down_.value || left_.value || right_.value ||
             pause_.value || b1_.value || b2_.value || esc_.value ||
             Game.mouse.button;
     });
    mute_ = new Button(function() { return state[0x4d]; });

    Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
    Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onRelease);

    if (ExternalInterface.available) {
      ExternalInterface.addCallback("uglJoystick", onJoystick);
    }
  }

  function onJoystick(x: Float, y: Float, b1: Bool, b2: Bool) {
    joyX = Math.abs(x) > joyEps ? x : 0;
    joyY = Math.abs(y) > joyEps ? y : 0;
    joyB1 = b1;
    joyB2 = b2;
  }

  function onPress(ev:KeyboardEvent) {
    state[ev.keyCode] = true;
  }

  function onRelease(ev:KeyboardEvent) {
    state[ev.keyCode] = false;
  }

  public function clear() {
    for (i in 0...state.length) {
      state[i] = false;
    }
    update();
  }

  public function update() {
    up_.update();
    down_.update();
    left_.update();
    right_.update();
    b1_.update();
    b2_.update();
    esc_.update();
    any_.update();
    mute_.update();
    pause_.update();
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
