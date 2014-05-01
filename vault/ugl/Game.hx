package vault.ugl;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import haxe.Timer;

enum GameState {
  TITLE;
  GAME;
  FINAL;
}

#if uglprof
class GroupProf {
  public var frames: Int = 0;
  public var count: Int = 0;
  public var max: Float = 0.0;
  public var sum: Float = 0.0;
}
#end

class Game {
  static var baseColor: Int = 0xFFFFFF;
  static public var name: String;
  static public var time(default, null): Float;
  static var _delay: Float;
  static var _time: Float;
  static public var currentTime(default, null): Float;
  static public var totalTime(default, null): Float;
  static public var key: Key;
  static public var mouse: Mouse;
  static public var main: Dynamic;
  function initialize() {}
  function begin() {}
  function update() {}
  function end() {}
  function final() {
    Game.clear();
    makeTitle();
    state = TITLE;
    mouse.clear();
    key.clear();
  }
  function finalupdate() {}

  static var groups: Map<String, EntityGroup>;
  static var sprite: Sprite;
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

  var state(default, set): GameState;

  var title: List<Entity>;
  var _title: String;
  var _version: String;

  var holdback: Float;

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

  static public function get(groupname: String): List<Entity> {
    return group(groupname, -1).entities;
  }

  static public function one(groupname: String): Dynamic {
    return group(groupname, -1).entities.first();
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

  static function beginGame() {
    mouse.update();
    key.update();

    totalTime = 0;
    Game.clear();
    main.begin();
  }

  function set_state(s: GameState): GameState {
    state = s;
    // clear input.
    Game.mouse.clear();
    Game.key.clear();
    return s;
  }

  static public function endGame() {
    if (main.state != GAME) return;

    main.holdback = 1.0;
    main.end();

    main.state = FINAL;
    main.final();
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

  static public function delay(t: Float) {
    _delay = Math.max(t, _delay);
  }

  static public function flash(color: UInt, ?t: Float = 0.01) {
    new Flasher(color, t);
  }

  public function new(title: String, version: String) {
    var cn = Type.getClassName(Type.getClass(this)).split(".");
    Game.name = cn[cn.length - 1];

    #if flash
    haxe.Log.setColor(baseColor);
    #end

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

    _title = title;
    _version = version;
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

    main = this;

    #if ugldebugfps
      average_fps = 0.0;
    #end

    sprite.addEventListener(Event.ADDED_TO_STAGE, onAdded);
    Lib.current.addChild(sprite);
  }

  function onAdded(ev) {
    sprite.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    #if flash
    Lib.current.stage.quality = StageQuality.BEST;
    Lib.current.stage.stageFocusRect = false;
    #end
    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    Lib.current.stage.align = StageAlign.TOP_LEFT;

    key = new Key();
    mouse = new Mouse();
    #if ugldebug
      state = GAME;
    #else
      state = TITLE;
    #end

    initialize();
    if (state == TITLE) {
      makeTitle();
    } else {
      beginGame();
    }

    Lib.current.addEventListener(Event.ENTER_FRAME, onFrame);
  }

  function makeTitle() {
    title = new List<Entity>();
    var s = 3;
    if (_title.length <= 20) s = 4;
    if (_title.length <= 15) s = 5;

    title.add(new Text().color(baseColor).text(_title).xy(240, 240).size(s));
    title.add(new Text().color(baseColor).text(_version).xy(240, 300).size(2));
    title.add(new Text().color(baseColor).text("click to begin").align(BOTTOM_CENTER).xy(240, 470).size(1));
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
        fps = new Text().xy(5, 480).align(BOTTOM_LEFT)
          .size(1).color(0xFF999999).text("FPS: " + Std.int(average_fps));
      #end
    #end

    key.update();
    mouse.update();

    // M key for mute.
    if (Game.key.mute_pressed) {
      Sound.mute = !Sound.mute;
    }

    switch (state) {
      case TITLE:
        if (Game.key.any_pressed) {
          state = GAME;
          Game.clear();
          beginGame();
        }
      case GAME:
        update();
      case FINAL:
        finalupdate();
        holdback = Math.max(0.0, holdback - _time);
        if (holdback == 0.0 && Game.key.any_pressed) {
          Game.clear();
          makeTitle();
          state = TITLE;
        }
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
    }

    Game.updateShake();

    if (key.esc_pressed) {
      endGame();
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
    }
  }
}

class Flasher extends Entity {
  static var layer = 99999;
  var duration = 0.0;
  override public function begin() {
    duration = args[1];
    alignment = TOPLEFT;
    pos.x = pos.y = 0;
    gfx.fill(args[0]).rect(0, 0, 480, 480);
  }

  override public function update() {
    if (ticks >= duration) remove();
  }
}

class EntityGroup extends Sprite {
  public var entities: List<Entity>;
  public var layer: Int = 10;

  public function new(name: String, layer: Int) {
    super();
    this.name = name;
    this.layer = layer;
    entities = new List<Entity>();
  }

  public function add(e: Entity) {
    addChild(e.base_sprite);
    entities.add(e);
  }

  public function remove(e: Entity) {
    removeChild(e.base_sprite);
    entities.remove(e);
  }
}

