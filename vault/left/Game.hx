package vault.left;

import flash.display.Sprite;
import flash.Lib;
import flash.events.Event;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import vault.left.Group;
import vault.left.Left;
import vault.left.Console.Profile;
import vault.left.View;
import haxe.Timer;

class Game extends Sprite {
  var frameCount: Int;
  var fps: Float;
  public var scene(default, null): Group;
  var nextscene: Void -> Group = null;

  public function new() {
    super();
    Left.console = new Console();
    Left.profile = new Profile();
    Left.game = this;

    Left.views = new Array<View>();
    Left.atlas = new Atlas();

    if (Lib.current.stage != null) {
      onAdded(null);
    } else {
      Lib.current.addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
  }

  function onAdded(ev: Event): Void {
    Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    Lib.current.addChild(this);

    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    Lib.current.stage.align = StageAlign.TOP_LEFT;

    Left.time = 0;
    frameCount = 0;
    fps = 0.0;
    Left.console.watch(this, "fps", "FPS");
    Left.key = new Key();
    Left.mouse = new Mouse();

    Lib.current.stage.addEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    onResize(null);
  }

  function onResize(ev) {
    Left.width = Lib.current.stage.stageWidth;
    Left.height = Lib.current.stage.stageHeight;
  }

  public function resetViews() {
    for (v in Left.views) {
      removeChild(v.sprite);
    }
    Left.views = [];
    addView(new View());
  }

  public function addView(v: View) {
    Left.views.push(v);
    addChild(v.sprite);
  }

  public function setScene(s: Void->Group) {
    this.nextscene = s;
    Left.time = 0;
  }

  function onFrame(ev) {
    Left.profile.start("left.update");

    if (this.nextscene != null) {
      if (numChildren > 0) {
        removeChildren(0, numChildren-1);
      }
      resetViews();
      var tmp = this.nextscene;
      this.nextscene = null;
      this.scene = tmp();
    }

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
    scene.update();

    for (view in Left.views) {
      view.update();
    }

    Left.profile.end("left.update");
    Left.profile.start("left.render");

    // draw
    for (view in Left.views) {
      view.render(scene);
    }

    Left.profile.end("left.render");

    Left.console.update();
    Left.profile.update();
  }
}
