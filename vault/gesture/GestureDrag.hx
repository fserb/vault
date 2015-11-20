package vault.gesture;

import vault.gesture.Gesture;
import vault.gesture.Gesture.GestureDetector;
import vault.gesture.GestureEvent;
import vault.geom.Vec2;

class GestureDrag extends GestureDetector {
  var triggered = false;
  var basePoint: Vec2;

  override public function handle(gesture: Gesture, ev: GestureEvent) {
    if (ev.fullTouches.length != 1) {
      return;
    }

    switch(ev.type) {
      case GestureEvent.GESTURE_BEGIN:
        triggered = false;

      case GestureEvent.GESTURE_MOVE:
        if (ev.delta.length < 40 && !triggered) {
          return;
        }

        if (!triggered) {
          ev.center.x = ev.initial.center.x;
          ev.center.y = ev.initial.center.y;
          gesture.trigger(GestureEvent.GESTURE_DRAG_BEGIN);
          this.triggered = true;
        }

        gesture.trigger(GestureEvent.GESTURE_DRAG_MOVE);

      case GestureEvent.GESTURE_END:
        if (this.triggered) {
          gesture.triggered = gesture.trigger(GestureEvent.GESTURE_DRAG_END);
          this.triggered = false;
        }
    }
  }
}
