package vault;

import flash.events.Event;
import flash.Lib;
import vault.Ease;
import vault.EMath;
import haxe.Timer;

typedef ActEvent = {
  var func: Float->Void;
  var time: Float;
  var duration: Float;
  var object: Dynamic;
  var hold: Bool;
}

class Act {
  static var loaded = false;
  static var actions: Array<ActEvent>;
  static var time: Float = 0;

  static function setup() {
    if (loaded) return;
    actions = [];
    Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    loaded = true;
  }

  static function onEnterFrame(ev: Event) {
    var blocked = new haxe.ds.ObjectMap<Dynamic, Bool>();

    var t = Timer.stamp();
    var elapsed = Math.min(0.1, (time > 0 ? t - time : 0));
    time = t;

    var i = 0;
    while (i < actions.length) {
      var a = actions[i++];
      var b = blocked.get(a.object);
      if (b == true) continue;
      blocked.set(a.object, a.hold);
      if (a.hold && b != null) continue;
      if (a.duration == 0.0) {
        a.func(0.0);
        actions.splice(i-1, 1);
        i--;
        continue;
      }
      if (a.duration < 0.0) continue;
      a.time = EMath.clamp(a.time + elapsed/a.duration, 0.0, 1.0);
      a.func(a.time);
      if (a.time >= 1.0) {
        actions.splice(i-1, 1);
        i--;
      }
    }
  }

  static public function obj(obj: Dynamic = null): Act {
    return new Act(obj);
  }

  static public function reset() {
    actions = [];
  }

  var object: Dynamic = null;
  var lastDuration: Float = 1.0;
  var lastEase: Float->Float = null;

  public function new(obj: Dynamic = null) {
    setup();
    object = obj != null ? obj : this;
    lastEase = Ease.linear;
  }

  public function stop(): Act {
    var i = 0;
    while (i < Act.actions.length) {
      if (Act.actions[i].object == object) {
        Act.actions.splice(i, 1);
      } else {
        i++;
      }
    }
    return this;
  }

  public function resume(): Act {
    var i = 0;
    while (i < Act.actions.length) {
      var a = Act.actions[i++];
      if (a.object == object && a.duration < 0 && a.hold == true) {
        Act.actions.splice(i-1, 1);
        i--;
      }
    }
    return this;
  }

  public function pause(): Act {
    Act.actions.insert(0, {
      func: function(t) {},
      time: 0,
      duration: -1,
      object: object,
      hold: true
      });
    return this;
  }

  public function delay(t: Float): Act {
    Act.actions.push({
      func: function(t) { return true; },
      time: 0,
      duration: t,
      object: object,
      hold: true});
    return this;
  }

  function getDeepProperty(obj: Dynamic, name: String): Dynamic {
    var p = name.indexOf('.');
    if (p == -1) {
      return Reflect.getProperty(obj, name);
    }
    return getDeepProperty(Reflect.getProperty(obj, name.substr(0, p)),
                           name.substr(p+1));
  }

  function setDeepProperty(obj: Dynamic, name: String, value: Dynamic) {
    var p = name.indexOf('.');
    if (p == -1) {
      return Reflect.setProperty(obj, name, value);
    }
    return setDeepProperty(Reflect.getProperty(obj, name.substr(0, p)),
                           name.substr(p+1), value);
  }

  public function attr(attr: String, value: Float, duration: Float = -1.0, ease: Float->Float = null): Act {
    if (ease == null) {
      ease = lastEase;
    }
    if (duration < 0.0) {
      duration = lastDuration;
    }
    lastDuration = duration;
    lastEase = ease;
    var initial: Null<Float> = null;
    var func = function(t: Float) {
      if (initial == null) {
        initial = getDeepProperty(object, attr);
      }
      setDeepProperty(object, attr, initial + (value - initial)*ease(t));
    };

    Act.actions.push({
      func: func,
      time: 0,
      duration: duration,
      object: object,
      hold: false});
    return this;
  }

  public function set(attr: String, value: Dynamic): Act {
    Act.actions.push({
      func: function(t) { setDeepProperty(object, attr, value); },
      time: 0,
      duration: 0,
      object: object,
      hold: true});
    return this;
  }

  public function incr(attr: String, value: Dynamic): Act {
    Act.actions.push({
      func: function(t) {
        var v = getDeepProperty(object, attr);
        setDeepProperty(object, attr, v + value); 
      },
      time: 0,
      duration: 0,
      object: object,
      hold: true});
    return this;
  }

  public function then(func: Void->Void = null): Act {
    Act.actions.push({
      func: function(t) { if (func != null) func(); },
      time: 0,
      duration: 0,
      object: object,
      hold: true});
    return this;
  }

  public function tween(func: Float->Void, duration: Float, ease: Float->Float = null): Act {
    if (ease == null) {
      ease = Ease.linear;
    }
    Act.actions.push({
      func: function(t: Float) { func(ease(t)); },
      time: 0,
      duration: duration,
      object: object,
      hold: false});
    return this;
  }
}
