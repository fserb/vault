package vault.ugl;

import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;
import vault.ugl.Key.Button;
import vault.Vec2;

class Touch {
  var evs: Map<Int, Vec2>;
  public var touches: Map<Int, Vec2>;
  public var press: Map<Int, Vec2>;

  public function new() {
    touches = new Map<Int, Vec2>();
    evs = new Map<Int, Vec2>();
    press = new Map<Int, Vec2>();

    Game.sprite.graphics.beginFill(0, 0.0);
    Game.sprite.graphics.drawRect(0,0,Game.width,Game.height);
    Game.sprite.graphics.endFill();
    Game.sprite.mouseChildren = false;

    if (Multitouch.supportsTouchEvents) {
      Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
      Game.sprite.addEventListener(TouchEvent.TOUCH_BEGIN, onPress);
      Game.sprite.addEventListener(TouchEvent.TOUCH_MOVE, onMove);
      Game.sprite.addEventListener(TouchEvent.TOUCH_END, onRelease);
    } else {
      Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
      Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
      Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
    }
  }

  function getID(ev: TouchEvent): Int {
    #if html5
      return ev.touchPointID != null ? ev.touchPointID : -1;
    #else
      return ev.touchPointID;
    #end
  }

  function onMove(ev: TouchEvent) {
    var id = getID(ev);
    if (!evs.exists(id)) return;
    evs[id].x = ev.localX;
    evs[id].y = ev.localY;
  }

  function onPress(ev: TouchEvent) {
    var id = getID(ev);
    evs[id] = new Vec2(ev.localX, ev.localY);
  }

  function onRelease(ev: TouchEvent) {
    var id = getID(ev);
    if (evs.exists(id)) {
      evs.remove(id);
    }
  }

  public function clear() {
    evs = new Map<Int, Vec2>();
    touches = new Map<Int, Vec2>();
    press = new Map<Int, Vec2>();
    update();
  }

  public function update() {
    for (e in evs.keys()) {
      if (!touches.exists(e) && !press.exists(e)) {
        press[e] = evs[e];
        touches[e] = evs[e];
      } else {
        if (press.exists(e)) {
          press.remove(e);
        }
        touches[e] = evs[e];
      }
    }
    for (e in touches.keys()) {
      if (!evs.exists(e)) {
        touches.remove(e);
      }
    }
    for (e in press.keys()) {
      if (!evs.exists(e)) {
        press.remove(e);
      }
    }
  }
}
