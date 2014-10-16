package vault.left;

import flash.events.MouseEvent;
import flash.Lib;
import vault.Vec2;

class Mouse {
  public var pos: Vec2;

  public var button: Bool;
  public var just: Bool;

  public function new() {
    pos = Vec2.make(0, 0);
    button = just = false;

    Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
  }

  function onMove(ev: MouseEvent) {
    pos.x = ev.localX;
    pos.y = ev.localY;
  }

  function onPress(ev: MouseEvent) {
    just = true;
    onMove(ev);
  }

  function onRelease(ev: MouseEvent) {
    just = button = false;
    onMove(ev);
  }

  public function update() {
    if (just) {
      if (!button) {
        button = true;
      } else {
        just = false;
      }
    }
  }
}
