package vault.ugl;

import flash.events.MouseEvent;
import flash.Lib;
import vault.ugl.Key.Button;

class Mouse {
  public var x: Float;
  public var y: Float;

  var button_: Button;
  var lmb: Bool;

  public var button(get, null): Bool;
  public var button_pressed(get, null): Bool;
  function get_button(): Bool { return button_.value; }
  function get_button_pressed(): Bool { return button_.just; }

  public function new() {
    x = y = 0;
    lmb = false;
    button_ = new Button(function() { return lmb; });

    Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
  }

  function onMove(ev: MouseEvent) {
    x = ev.stageX;
    y = ev.stageY;
  }

  function onPress(ev: MouseEvent) {
    lmb = true;
    onMove(ev);
  }

  function onRelease(ev: MouseEvent) {
    lmb = false;
    onMove(ev);
  }

  public function update() {
    button_.update();
  }
}
