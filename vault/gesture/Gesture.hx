package vault.gesture;

import flash.events.EventDispatcher;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;

import vault.gesture.GestureEvent;

import vault.Vec2;

class GestureDetector {
  public function new() { }

  public function handle(gesture: Gesture, ev: GestureEvent) { }
}

class Gesture {
  var touches: Map<Int, Vec2>;

  var current: GestureEvent;

  static var gestures: Array<GestureDetector> = [
    new vault.gesture.GestureTouch(),
    new vault.gesture.GestureTransform(),
    new vault.gesture.GestureDrag(),
    new vault.gesture.GestureTap(),
    new vault.gesture.GestureSwipe(),
    new vault.gesture.GestureHold(),
  ];

  var target: EventDispatcher;

  public var triggered: GestureEvent;
  public var isTouch: Bool;

  public function registerDetector(g: GestureDetector) {
    gestures.push(g);
  }

  public function new(target: EventDispatcher) {
    this.target = target;
    touches = new Map<Int, Vec2>();

    isTouch = Multitouch.supportsTouchEvents;
    #if html5
      // For HTML5, supportsTouchEvents seems kinda broken.
      // So we fallback to detecting if it's a mobile browser or not.
      isTouch = false;
      if (~/android/i.match(js.Browser.navigator.userAgent)) {
        isTouch = true;
      }
    #end

    if (isTouch) {
      Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
      target.addEventListener(TouchEvent.TOUCH_BEGIN, touchEvent);
      target.addEventListener(TouchEvent.TOUCH_MOVE, touchEvent);
      target.addEventListener(TouchEvent.TOUCH_END, touchEvent);
    } else {
      target.addEventListener(MouseEvent.MOUSE_DOWN, mouseEvent);
      target.addEventListener(MouseEvent.MOUSE_MOVE, mouseEvent);
      target.addEventListener(MouseEvent.MOUSE_UP, mouseEvent);
    }
  }

  public function detach() {
    if (isTouch) {
      target.removeEventListener(TouchEvent.TOUCH_BEGIN, touchEvent);
      target.removeEventListener(TouchEvent.TOUCH_MOVE, touchEvent);
      target.removeEventListener(TouchEvent.TOUCH_END, touchEvent);
    } else {
      target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseEvent);
      target.removeEventListener(MouseEvent.MOUSE_MOVE, mouseEvent);
      target.removeEventListener(MouseEvent.MOUSE_UP, mouseEvent);
    }
  }

  function mouseEvent(ev: MouseEvent) {
    switch(ev.type) {
      case MouseEvent.MOUSE_DOWN:
        touches[0] = new Vec2(ev.stageX, ev.stageY);
        gestureStart();
      case MouseEvent.MOUSE_MOVE:
        touches[0] = new Vec2(ev.stageX, ev.stageY);
        gestureMove();
      case MouseEvent.MOUSE_UP:
        touches[0] = new Vec2(ev.stageX, ev.stageY);
        gestureEnd();
        touches.remove(0);
    }
  }

  function touchEvent(ev: TouchEvent) {
    switch(ev.type) {
      case TouchEvent.TOUCH_BEGIN:
        touches[ev.touchPointID] = new Vec2(ev.stageX, ev.stageY);
        gestureStart();
      case TouchEvent.TOUCH_MOVE:
        touches[ev.touchPointID] = new Vec2(ev.stageX, ev.stageY);
        gestureMove();
      case TouchEvent.TOUCH_END:
        touches[ev.touchPointID] = new Vec2(ev.stageX, ev.stageY);
        gestureEnd();
        touches.remove(ev.touchPointID);
    }
  }

  public function trigger(type: String): GestureEvent {
    var ev = new GestureEvent(type, touches, current);
    target.dispatchEvent(ev);
    return ev;
  }

  function gestureStart() {
    current = new GestureEvent(GestureEvent.GESTURE_BEGIN, touches, null);
    triggered = null;
    for(g in gestures) {
      g.handle(this, current);
    }
  }

  function gestureMove() {
    if (current == null) {
      return;
    }

    current = new GestureEvent(GestureEvent.GESTURE_MOVE, touches, current);
    triggered = null;
    for(g in gestures) {
      g.handle(this, current);
    }

  }

  function gestureEnd() {
    if (current == null) {
      return;
    }

    var count = 0;
    for (k in touches) {
      count += 1;
    }
    if (count > 1) {
      return gestureMove();
    }
    current = new GestureEvent(GestureEvent.GESTURE_END, touches, current);
    triggered = null;
    for(g in gestures) {
      g.handle(this, current);
    }
    current = null;
  }

}
