package vault.act;

import flash.events.Event;
import flash.Lib;

typedef ActEvent = {
  var func: Float->Void;
  var duration: Float;
  var property: String;
}

class Act {
  static var loaded = false;
  static var actions: Array<Act>;

  static function setup() {
    if (loaded) return;
    actions = [];
    Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    loaded = true;
  }

  static function onEnterFrame(ev: Event) {
    for (a in actions) {
      if (!a.run()) {
        actions.remove(a);
      }
    }
  }

  static public function obj(obj: Dynamic): Act {
    var act = new Act(obj);
    return null;
  }

  var object: Dynamic = null;
  var sequence: Array<ActEvent>;

  public function new(obj: Dynamic) {
    object = obj;
    sequence = [];
    Act.actions.push(this);
  }

  function run(): Bool {
    for (s in sequence) {

    }
    return true;
  }

  public function delay(t: Float): Act {
    sequence.push({ null, t, null});
    return this;
  }

  public function attr(attr: String, value: Dynamic, duration: Float, ease: Float->Float): Act {
    return this;
  }

  public function then(func: Void->Void): Act {
    return this;
  }

  public function tween(func: Void->Void, duration: Float, ease: Float->Float): Act {
    return this;
  }

}
