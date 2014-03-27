import flash.display.Sprite;
import flash.events.TouchEvent;

import vault.gesture.Gesture;
import vault.gesture.GestureEvent;


class GestureTest extends Sprite {
  var gest: Gesture;

  public function new() {
    super();

    graphics.beginFill(0xCCCCCC);
    graphics.drawRect(0, 0, flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight);
    trace(width + ", " + height);

    gest = new Gesture(this);
    trace("Hello");

    addEventListener(GestureEvent.GESTURE_BEGIN, act);
    addEventListener(GestureEvent.GESTURE_END, act);
    addEventListener(GestureEvent.GESTURE_MOVE, act);

    addEventListener(GestureEvent.GESTURE_TAP, act);
    addEventListener(GestureEvent.GESTURE_TAP_1, act);
    addEventListener(GestureEvent.GESTURE_TAP_2, act);
    addEventListener(GestureEvent.GESTURE_TAP_3, act);
    addEventListener(GestureEvent.GESTURE_TAP_4, act);
    addEventListener(GestureEvent.GESTURE_TAP_5, act);

    addEventListener(GestureEvent.GESTURE_SWIPE, act);
    addEventListener(GestureEvent.GESTURE_SWIPE_UP, act);
    addEventListener(GestureEvent.GESTURE_SWIPE_DOWN, act);
    addEventListener(GestureEvent.GESTURE_SWIPE_LEFT, act);
    addEventListener(GestureEvent.GESTURE_SWIPE_RIGHT, act);

    addEventListener(GestureEvent.GESTURE_TRANSFORM_BEGIN, act);
    addEventListener(GestureEvent.GESTURE_TRANSFORM_MOVE, act);
    addEventListener(GestureEvent.GESTURE_TRANSFORM_END, act);
    addEventListener(GestureEvent.GESTURE_TRANSFORM_ROTATE, act);
    addEventListener(GestureEvent.GESTURE_TRANSFORM_PINCH, act);
    addEventListener(GestureEvent.GESTURE_TRANSFORM_PINCH_IN, act);
    addEventListener(GestureEvent.GESTURE_TRANSFORM_PINCH_OUT, act);
  }

  function act(ev: GestureEvent) {
    trace(ev);
  }
}
