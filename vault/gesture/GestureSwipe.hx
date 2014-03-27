package vault.gesture;

import vault.gesture.Gesture;
import vault.gesture.Gesture.GestureDetector;
import vault.gesture.GestureEvent;

class GestureSwipe extends GestureDetector {
  override public function handle(gesture: Gesture, ev: GestureEvent) {
    if (ev.type == GestureEvent.GESTURE_END) {
      if (ev.velocity.length() > 700) {
        if (gesture.triggered == null) {
          gesture.triggered = gesture.trigger(GestureEvent.GESTURE_SWIPE);
          gesture.trigger(GestureEvent.GESTURE_SWIPE + ev.direction);
        }
      }
    }
  }
}

