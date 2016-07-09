package vault.deck;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.Lib;
import haxe.Timer;
import vault.geom.Point;

class Game {
  public function begin() {}

  static public var width: Int;
  static public var height: Int;
  static public var time: Float;
  static public var currentTime(default, null): Float;
  static public var totalTime: Float;
  static public var scene: Dynamic;

  static public var touch: Touch;

  static var desiredSize: Point = null;

  static public var sprite: Sprite;

  static public var entities: Array<Entity>;

  public function new() {
    scene = this;
    sprite = new Sprite();
    time = 0;
    totalTime = 0;
    currentTime = Timer.stamp();

    entities = [];
    if (Lib.current.stage != null) {
      onAdded(null);
    } else {
      Lib.current.addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
  }

  function onAdded(ev) {
    Lib.current.addChild(sprite);
    sprite.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    touch = new Touch();

    Lib.current.addEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    onResize(null);
  }

  function onFrame(ev) {
    Lib.current.stage.focus = sprite;

    var t = Timer.stamp();
    time = t - currentTime;
    currentTime = t;
    totalTime += time;

    touch.update();
    for (t in touch.press) {
      var top: Entity = null;
      for (e in entities) {
        if (!e.touchable) continue;
        if (top != null && top.layer >= e.layer) continue;
        if (!e.aabb.contains(t.x, t.y)) continue;
        top = e;
      }
      if (top != null) {
        top._touch();
      }
    }

    for (e in entities) {
      e._update();
    }
    Game.gc();

    entities.sort(function(a, b) {
      var x = a.layer - b.layer;
      if (x > 0) return 1;
      if (x < 0) return -1;
      return 0;
    });
    for (i in 0...entities.length) {
      sprite.setChildIndex(entities[i].sprite, i);
    }

    Game.updateShake();
  }

  function onResize(ev) {
    if (desiredSize == null) {
      Game.width = Lib.current.stage.stageWidth;
      Game.height = Lib.current.stage.stageHeight;
    } else {
      var w = desiredSize.x;
      var h = desiredSize.y;
      Game.width = w;
      Game.height = h;
      var zoom = Math.min(Lib.current.stage.stageWidth/w, Lib.current.stage.stageHeight/h);
      Lib.current.scaleX = Lib.current.scaleY = zoom;
      Lib.current.x = (Lib.current.stage.stageWidth/zoom - w)/2.0;
      Lib.current.y = (Lib.current.stage.stageHeight/zoom - h)/2.0;
    }
    Game.clear();
    begin();
  }

  static public function clear() {
    for (e in entities) {
      e.dead = true;
    }
    Game.gc();
    Act.reset();
  }

  static public function gc() {
    for (e in entities) {
      if (e.dead) {
        sprite.removeChild(e.sprite);
        entities.remove(e);
      }
    }
  }

  static var shaking = 0.0;
  static public function shake(?t: Float = 0.4) {
    shaking = Math.max(shaking, t);
  }

  static function updateShake() {
    shaking = Math.max(0.0, shaking - time);
    if (shaking <= 0) {
      sprite.x = sprite.y = 0;
      return;
    }

    var mag = 5 + 10*shaking;
    sprite.x = -mag + 2*mag*Math.random();
    sprite.y = -mag + 2*mag*Math.random();
  }

  public static function forceSize(w: Int, h: Int) {
    desiredSize = new Point(w, h);
  }

  static public function all(n : String): Array<Dynamic> {
    var r = new Array<Dynamic>();
    for (e in entities) {
      if (e.className == n) {
        r.push(e);
      }
    }
    return r;
  }

  static public function one(n: String): Dynamic {
    for (e in entities) {
      if (e.className == n) {
        return e;
      }
    }
    return null;
  }
}
