package vault.gesture;

import vault.gesture.Gesture;
import vault.gesture.Gesture.GestureDetector;
import vault.gesture.GestureEvent;

class GestureTouch extends GestureDetector {
  override public function handle(gesture: Gesture, ev: GestureEvent) {
    gesture.trigger(ev.type);
  }
}

