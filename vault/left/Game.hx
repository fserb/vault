package vault.left;

import flash.display.Sprite;
import flash.Lib;
import flash.events.Event;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import vault.left.Group;
import vault.left.Left;
import vault.left.View;

class Game extends Sprite {
  var currentTime: Float;
  var scene(default, set): Group;

  var partialAdded: Event -> Void;
  public function new(scene: Group) {
    super();

    Left.game = this;

    partialAdded = onAdded.bind(_, scene);
    if (Lib.current.stage != null) {
      onAdded(null, scene);
    } else {
      Lib.current.addEventListener(Event.ADDED_TO_STAGE, partialAdded);
    }
  }

  function onAdded(ev: Event, scene:Group): Void {
    Lib.current.removeEventListener(Event.ADDED_TO_STAGE, partialAdded);

    Lib.current.addChild(this);

    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
    Lib.current.stage.align = StageAlign.TOP_LEFT;

    currentTime = Lib.getTimer();

    Lib.current.stage.addEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    onResize(null);
    this.scene = scene;
  }

  function onResize(ev) {
    Left.width = Lib.current.stage.stageWidth;
    Left.height = Lib.current.stage.stageHeight;
  }

  public function set_scene(s: Group): Group {
    this.scene = s;
    Left.view = new View(Left.width, Left.height);
    if (numChildren > 0) {
      removeChildren(0, numChildren-1);
    }
    addChild(Left.view.sprite);
    return this.scene;
  }

  function onFrame(ev) {
    var t = Lib.getTimer();
    Left.elapsed = (t - currentTime)/1000.0;
    currentTime = t;
    trace(Left.elapsed + " - FPS: " + 1/Left.elapsed);

    // input
    // TODO: keyboard/gamepad/mouse input update

    // update
    scene.update();

    // draw
    Left.view.render(scene);
  }
}
