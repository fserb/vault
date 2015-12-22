package vault.left;

import flash.events.MouseEvent;
import flash.Lib;
import vault.geom.Vec2;

class Mouse {
  public var pos: Vec2;

  public var button: Bool;
  public var just: Bool;
  public var moved: Bool;

  var lastpos: Vec2;

  public function new() {
    pos = new Vec2(0, 0);
    lastpos = new Vec2(0, 0);
    button = just = false;

    Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
  }

  function onMove(ev: MouseEvent) {
    pos.x = ev.stageX;
    pos.y = ev.stageY;
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
    if (lastpos.x != pos.x || lastpos.y != pos.y) {
      moved = true;
      lastpos.x = pos.x;
      lastpos.y = pos.y;
    } else {
      moved = false;
    }
    if (just) {
      if (!button) {
        button = true;
      } else {
        just = false;
      }
    }
  }
}
