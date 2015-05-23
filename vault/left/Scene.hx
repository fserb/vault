package vault.left;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.Lib;
import flash.events.Event;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.StageQuality;
import vault.left.Left;
import vault.left.Console.Profile;
import haxe.Timer;

@:allow(vault.left.Left)
class Scene extends Sprite {
  var frameCount: Int;
  var fps: Float;
  public var fullscreen(default, set): Bool;

  public var paused: Bool = false;

  var desiredWidth: Int = 0;
  var desiredHeight: Int = 0;
  public var zoom: Float = 1.0;

  public function new() {
    super();
    Left.console = new Console();
    Left.profile = new Profile();

    Left.scene = this;

    if (Lib.current.stage != null) {
      onAdded(null);
    } else {
      Lib.current.addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
  }

  function onAdded(ev: Event): Void {
    Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    Lib.current.addChild(this);

    #if (android || ios)
      Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
      Lib.current.stage.align = StageAlign.TOP_LEFT;
    #else
      Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
      Lib.current.stage.align = StageAlign.TOP;
      Lib.current.stage.quality = StageQuality.BEST;
    #end

    Left.time = 0;
    frameCount = 0;
    fps = 0.0;
    paused = false;
    Left.console.watch(this, "fps", "FPS");
    Left.key = new Key();
    Left.mouse = new Mouse();

    Lib.current.stage.addEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    onResize(null);
  }

  public function forceSize(width: Int = 0, height: Int = 0): Float {
    desiredWidth = width;
    desiredHeight = height;
    onResize(null);
    return zoom;
  }

  function onResize(ev) {
    Left.width = Lib.current.stage.stageWidth;
    Left.height = Lib.current.stage.stageHeight;
    if (desiredWidth * desiredHeight != 0) {
      zoom = Math.min(Left.width/desiredWidth, Left.height/desiredHeight);
    } else {
      zoom = 1.0;
    }
    Lib.current.scaleX = Lib.current.scaleY = zoom;
    Left.width = Math.floor(Left.width/zoom);
    Left.height = Math.floor(Left.height/zoom);
    if (desiredWidth * desiredHeight != 0) {
      Lib.current.x = (Left.width - desiredWidth)/2.0;
      Lib.current.y = (Left.height - desiredHeight)/2.0;
    } else {
      Lib.current.x = Lib.current.y = 0;
    }
  }

  function set_fullscreen(value: Bool): Bool {
    if (!value) {
      Lib.current.stage.displayState = StageDisplayState.NORMAL;
    } else {
      Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN;
    }

    fullscreen = value;
    return value;
  }

  function update() {
  }

  function onDestroy() {
    Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.stage.removeEventListener(Event.RESIZE, onResize);
    Lib.current.removeChild(this);
  }

  function onFrame(ev) {
    Left.profile.start("left.update");

    frameCount++;
    var t = Timer.stamp();
    Left.elapsed = Math.min(0.1, (Left.time > 0 ? t - Left.time : 0));
    Left.time = t;
    if (Left.elapsed > 0) {
      fps = Math.round((9.0*fps + 1.0/Left.elapsed)/10.0);
    }

    // input
    Left.key.update();
    Left.mouse.update();

    // update
    update();

    if (paused) return;

    Left.profile.end("left.update");

    Left.console.update();
    Left.profile.update();
  }
}
