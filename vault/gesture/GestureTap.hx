package vault.gesture;

import vault.gesture.Gesture;
import vault.gesture.Gesture.GestureDetector;
import vault.gesture.GestureEvent;

class GestureTap extends GestureDetector {
  override public function handle(gesture: Gesture, ev: GestureEvent) {
    if (ev.type == GestureEvent.GESTURE_END) {
      if (ev.deltaTime < 0.250 && ev.delta.length < 100) {
        if (gesture.triggered == null) {
          gesture.triggered = gesture.trigger(GestureEvent.GESTURE_TAP);
          gesture.trigger(GestureEvent.GESTURE_TAP + ev.initial.touches.length);
        }
      }
    }
  }
}

