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
  var scene: Group;
  var nextscene: Void -> Group = null;

  public function new() {
    super();
    Left.game = this;

    Left.views = new Array<View>();

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

    currentTime = Lib.getTimer();

    Lib.current.stage.addEventListener(Event.ENTER_FRAME, onFrame);
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    onResize(null);
  }

  function onResize(ev) {
    Left.width = Lib.current.stage.stageWidth;
    Left.height = Lib.current.stage.stageHeight;
  }

  public function addView(v: View) {
    Left.views.push(v);
    addChild(v.sprite);
  }

  public function setScene(s: Void->Group) {
    this.nextscene = s;
  }

  function onFrame(ev) {
    if (this.nextscene != null) {
      Left.views = [];
      if (numChildren > 0) {
        removeChildren(0, numChildren-1);
      }
      addView(new View());
      this.scene = this.nextscene();
      this.nextscene = null;
    }

    var t = Lib.getTimer();
    Left.elapsed = (t - currentTime)/1000.0;
    currentTime = t;
    trace(Left.elapsed + " - FPS: " + 1/Left.elapsed);

    // input
    // TODO: keyboard/gamepad/mouse input update

    // update
    scene.update();

    // draw
    for (view in Left.views) {
      view.render(scene);
    }
  }
}
