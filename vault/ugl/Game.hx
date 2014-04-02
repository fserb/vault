package vault.ugl;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import haxe.Timer;

class Game {
  static public var time(default, null): Float;
  static public var currentTime(default, null): Float;
  static public var totalTime(default, null): Float;
  static public var key: Key;
  static public var mouse: Mouse;
  static public var main: Dynamic;
  function initialize() {}
  function begin() {}
  function update() {}
  function end() {}

  static var groups: Map<String, EntityGroup>;
  static var sprite: Sprite;
  static public var debugsprite: Sprite;

  static public var debug = false;
  var fps: Text;
  var average_fps: Float;

  var inTitle = true;
  var title: List<Entity>;
  var _title: String;
  var _version: String;

  static public function group(groupname: String): EntityGroup {
    var g = groups.get(groupname);
    if (g != null) return g;

    var g = new EntityGroup();
    groups.set(groupname, g);
    sprite.addChild(g);

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
    return group(groupname).entities;
  }

  static public function orderGroups(names: Array<String>) {
    // make sure we have all groups.
    for (n in names) {
      get(n);
    }

    for (i in 0...names.length) {
      sprite.setChildIndex(groups.get(names[i]), i);
    }
  }

  static public function endGame() {
    main.end();
    // clear input.
    mouse.update();
    key.update();
    main.makeTitle();
  }

  public function new(title: String, version: String) {
    #if flash
    haxe.Log.setColor(0xEEEEEE);
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

    sprite = new Sprite();
    debugsprite = new Sprite();
    if (debug) {
      sprite.addChild(debugsprite);
    }
    time = 0;
    totalTime = 0;
    currentTime = Timer.stamp();

    main = this;

    if (debug) {
      average_fps = 0.0;
    }

    sprite.addEventListener(Event.ADDED_TO_STAGE, onAdded);
    Lib.current.addChild(sprite);
  }

  function onAdded(ev) {
    sprite.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    #if flash
    Lib.current.stage.stageFocusRect = false;
    #end
    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    Lib.current.stage.align = StageAlign.TOP_LEFT;

    key = new Key();
    mouse = new Mouse();

    initialize();
    makeTitle();

    Lib.current.addEventListener(Event.ENTER_FRAME, onFrame);
  }

  function makeTitle() {
    title = new List<Entity>();
    title.add(new Text().text(_title).xy(240, 240).size(_title.length <= 15 ? 5 : 4));
    title.add(new Text().text(_version).xy(240, 300).size(2));
    title.add(new Text().text("click to begin").align(BOTTOM_CENTER).xy(240, 470).size(1).color(0xFF999999));
    inTitle = true;
  }

  function onFrame(ev) {
    Lib.current.stage.focus = sprite;

    var t = Timer.stamp();
    time = t - currentTime;
    totalTime += time;
    currentTime = t;

    if (debug) {
      debugsprite.x = debugsprite.y = 0;
      sprite.setChildIndex(debugsprite, sprite.numChildren - 1);
      debugsprite.graphics.clear();
      debugsprite.graphics.beginFill(0x000000, 0.0);
      debugsprite.graphics.lineStyle(null);
      debugsprite.graphics.drawRect(0,0,480,480);
      average_fps = (59.0*average_fps + 1.0/Game.time)/60.0;
      if (fps != null) fps.remove();
      fps = new Text().xy(5, 480).align(BOTTOM_LEFT)
        .size(1).color(0xFFFFFFFF).text("FPS: " + Std.int(average_fps));
    }

    key.update();
    mouse.update();

    if (inTitle) {
      if (Game.mouse.button_pressed || Game.key.b1_pressed || Game.key.b2_pressed ||
          Game.key.up_pressed || Game.key.down_pressed || Game.key.left_pressed ||
          Game.key.right_pressed || debug) {
        inTitle = false;
        Game.clear();
        // clear input updates
        mouse.update();
        key.update();
        begin();
      }
    } else {
      update();
    }

    for (g in groups) {
      for (e in g.entities) {
        if (e.dead) {
          g.remove(e);
        } else {
          e._update();
        }
      }
    }

    if (key.esc_pressed) {
      endGame();
    }
  }
}


class EntityGroup extends Sprite {
  public var entities: List<Entity>;

  public function new() {
    super();
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

