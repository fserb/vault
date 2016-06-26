package vault.ugl;

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

#if uglprof
class GroupProf {
  public var frames: Int = 0;
  public var count: Int = 0;
  public var max: Float = 0.0;
  public var sum: Float = 0.0;
}
#end

class Game {
  static public var name: String;
  static public var width: Int;
  static public var height: Int;
  static public var time: Float;
  static var _delay: Float;
  static public var _time(default, null): Float;
  static public var currentTime(default, null): Float;
  static public var totalTime: Float;
  static public var key: Key;
  static public var mouse: Mouse;
  static public var touch: Touch;
  static public var scene(default, set): Dynamic;

  static var groups: Map<String, EntityGroup>;
  static public var sprite: Sprite;
  #if ugldebug
    static public var debugsprite: Sprite;
  #end

  #if ugldebugfps
  var fps: Text;
  var average_fps: Float;
  #end

  #if uglprof
  static var profcounts: Map<String, GroupProf>;
  #end

  var fullscreen(default, set): Bool;

  static public function set_scene(s: Scene): Scene {
    if (Game.scene != null) {
      Game.scene.onEnd();
    }
    Game.scene = s;
    #if uglprof
    for (k in profcounts.keys()) {
      var g = profcounts.get(k);
      var c = g.count > 0 ? g.count : 1;
      trace(
        k + ": " +
        g.count + " updates (" + Std.int(g.count/g.frames) + " upf) - " +
        Std.int(g.sum*1000) + "ms total - " +
        Std.int(1000000*g.sum/g.count) + "us - " +
        "max: " + Std.int(100000*g.max) + "us");
    }
    #end
    return s;
  }

  static public function group(groupname: String, layer: Int): EntityGroup {
    var g = groups.get(groupname);
    if (g != null) {
      if (g.layer == -1) {
        g.layer = layer;
        sortLayers();
      }
      return g;
    }

    var g = new EntityGroup(groupname, layer);
    groups.set(groupname, g);
    sprite.addChild(g);
    #if uglprof
      profcounts.set(groupname, new GroupProf());
    #end

    if (layer != -1) {
      sortLayers();
    }

    return g;
  }

  static public function clear(?groupname: Array<String>=null) {
    if (groupname == null) {
      for (gn in groups.keys()) {
        for (g in Game.get(gn)) {
          g.remove();
        }
      }
      return;
    }

    for (gn in groupname) {
      for (g in Game.get(gn)) {
        g.remove();
      }
    }
  }

  static public function gc() {
    for (g in groups) {
      for (e in g.entities) {
        if (e.dead) {
          g.remove(e);
        }
      }
    }
  }

  static public function get(groupname: String): Array<Entity> {
    return group(groupname, -1).entities;
  }

  static public function one(groupname: String): Dynamic {
    var g = group(groupname, -1);
    if (g.entities.length == 0) return null;
    return g.entities[0];
  }

  static public function orderGroups(names: Array<String>) {
    for (i in 0...names.length) {
      group(names[i], -1).layer = 20 + i;
    }
    sortLayers();
  }

  static function sortLayers() {
    var layers = new Array<String>();
    for (k in groups.keys()) {
      layers.push(k);
    }
    layers.sort(function(a, b) {
      var la = groups.get(a).layer;
      var lb = groups.get(b).layer;
      if (la > lb) return 1;
      if (la < lb) return -1;
      return 0;
    });
    for (i in 0...layers.length) {
      sprite.setChildIndex(groups.get(layers[i]), i);
    }
  }

  static var shaking = 0.0;
  static public function shake(?t: Float = 0.4) {
    shaking = Math.max(shaking, t);
  }

  static function updateShake() {
    shaking = Math.max(0.0, shaking - _time);
    if (shaking <= 0) {
      sprite.x = sprite.y = 0;
      return;
    }

    var mag = 5 + 10*shaking;
    sprite.x = -mag + 2*mag*Math.random();
    sprite.y = -mag + 2*mag*Math.random();
  }

  public static function forceSize(w: Int, h: Int) {
    Game.width = w;
    Game.height = h;
    var zoom = Math.min(Lib.current.stage.stageWidth/w, Lib.current.stage.stageHeight/h);
    Lib.current.scaleX = Lib.current.scaleY = zoom;
    Lib.current.x = (Lib.current.stage.stageWidth/zoom - w)/2.0;
    Lib.current.y = (Lib.current.stage.stageHeight/zoom - h)/2.0;
  }


  static public function delay(t: Float) {
    _delay = Math.max(t, _delay);
  }

  public function new(scene:Scene) {
    var oldtrace = haxe.Log.trace;
    haxe.Log.trace = function(v, ?posInfos) {
      v = Std.string(v);
      #if flash
        Lib.trace(posInfos.className + "#" +
                  posInfos.methodName + "(" +
                  posInfos.lineNumber + "):" + v);
        haxe.Log.clear();
      #end
      oldtrace(v, posInfos);
    }

    groups = new Map<String, EntityGroup>();
    #if uglprof
    profcounts = new Map<String, GroupProf>();
    #end

    sprite = new Sprite();
    #if ugldebug
      debugsprite = new Sprite();
      sprite.addChild(debugsprite);
    #end
    time = _time = _delay = 0;
    totalTime = 0;
    currentTime = Timer.stamp();

    if (scene != null) {
      Game.scene = scene;
    } else {
      Game.scene = new Scene();
    }

    #if ugldebugfps
      average_fps = 0.0;
    #end

    if (Lib.current.stage != null) {
      onAdded(null);
    } else {
      Lib.current.addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }

    if (ExternalInterface.available) {
      ExternalInterface.addCallback("uglGameInfo", onGameInfo);
      ExternalInterface.addCallback("pause", onDeactivate);
    }
  }

  function onAdded(ev) {
    Lib.current.addChild(sprite);
    sprite.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    Game.width = Lib.current.stage.stageWidth;
    Game.height = Lib.current.stage.stageHeight;

    #if flash
    Lib.current.stage.quality = StageQuality.BEST;
    Lib.current.stage.stageFocusRect = false;
    Lib.current.stage.fullScreenSourceRect = new Rectangle(0, 0,
      width, height);
    #end

    key = new Key();
    mouse = new Mouse();
    touch = new Touch();

    #if !tabletop
      scene.onBegin();
    #end

    Lib.current.addEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.addEventListener(Event.DEACTIVATE, onDeactivate);
    Lib.current.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    #if tabletop
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    #end
  }

  #if tabletop
  function onResize(ev) {
    Game.width = Lib.current.stage.stageWidth;
    Game.height = Lib.current.stage.stageHeight;
    scene.onBegin();
  }
  #end

  function set_fullscreen(value: Bool): Bool {
    trace("fullscreen", fullscreen, value);
    if (fullscreen && !value) {
      Lib.current.stage.displayState = StageDisplayState.NORMAL;
    } else if (!fullscreen && value) {
      Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN;
    }

    fullscreen = value;
    return value;
  }

  function onKeyUp(ev) {
    if (ev.keyCode == 0x46) {
      fullscreen = !fullscreen;
    }
  }

  function onDeactivate(ev) {
    #if !tabletop
      scene.onBackground();
    #end
  }

  function onFrame(ev) {
    Lib.current.stage.focus = sprite;

    var t = Timer.stamp();
    time = _time = t - currentTime;
    currentTime = t;
    #if ugldebug
      if (_time >= 0.1) {
        trace("slow frame: " + _time);
      }
    #end
    if (_delay > 0) {
      _delay -= _time;
      time = 0;
      return;
    }
    totalTime += time;

    #if ugldebug
      debugsprite.x = debugsprite.y = 0;
      sprite.setChildIndex(debugsprite, sprite.numChildren - 1);
      debugsprite.graphics.clear();
      #if ugldebugfps
        if (_time > 0) {
          average_fps = (59.0*average_fps + 1.0/_time)/60.0;
        }
        if (fps != null) fps.remove();
        fps = new Text().xy(5, Game.height).align(BOTTOM_LEFT)
          .size(1).color(0xFF999999).text("FPS: " + Std.int(average_fps));
      #end
    #end

    key.update();
    mouse.update();
    touch.update();
    if (!scene.onFrame()) {
      return;
    }

    for (g in groups) {
      #if uglprof
      var gp:GroupProf = profcounts.get(g.name);
      gp.frames++;
      #end
      for (e in g.entities) {
        #if uglprof
          var start = Timer.stamp();
        #end
        if (e.dead) {
          g.remove(e);
        } else {
          e._update();
        }
        #if uglprof
          var d = Timer.stamp() - start;
          gp.count++;
          gp.sum += d;
          gp.max = Math.max(gp.max, d);
        #end
      }
      g.newentities = g.entities;
    }

    Game.updateShake();
    scene.onEndFrame();
  }

  function onGameInfo() {
    return { "bgcolor": "#" + StringTools.hex(Lib.current.stage.color, 6),
             "name": Game.name,
             "width": Game.width,
             "height": Game.height };
  }
}

class EntityGroup extends Sprite {
  public var entities: Array<Entity>;
  public var newentities: Array<Entity>;

  public var layer: Int = 10;

  public function new(name: String, layer: Int) {
    super();
    this.name = name;
    this.layer = layer;
    newentities = entities = new Array<Entity>();
  }

  public function add(e: Entity) {
    addChild(e.base_sprite);
    entities.push(e);
  }

  public function sort() {
    if (entities == newentities) {
      newentities = entities.copy();
    }
    newentities.sort(function(a, b) return a.innerlayer - b.innerlayer);
    for (i in 0...newentities.length) {
      setChildIndex(newentities[i].base_sprite, i);
    }
  }

  public function remove(e: Entity) {
    removeChild(e.base_sprite);
    entities.remove(e);
  }
}
