package vault.gesture;

import vault.gesture.Gesture;
import vault.gesture.Gesture.GestureDetector;
import vault.gesture.GestureEvent;

class GestureTransform extends GestureDetector {
  var triggered = false;

  override public function handle(gesture: Gesture, ev: GestureEvent) {
    if (ev.fullTouches.length < 2) {
      return;
    }

    switch(ev.type) {
      case GestureEvent.GESTURE_BEGIN:
        triggered = false;

      case GestureEvent.GESTURE_MOVE:
        var scale_threshold = Math.abs(1 - ev.scale);
        var rotation_threshold = Math.abs(ev.rotation);

        // when the distance we moved is too small we skip this gesture
        // or we can be already in dragging
        if(scale_threshold < 0.075 &&
          rotation_threshold < 4*Math.PI/180) {
          return;
        }

        if (!this.triggered) {
          gesture.trigger(GestureEvent.GESTURE_TRANSFORM_BEGIN);
          this.triggered = true;
        }

        gesture.trigger(GestureEvent.GESTURE_TRANSFORM_MOVE);

        if (rotation_threshold >= Math.PI/180) {
          gesture.trigger(GestureEvent.GESTURE_TRANSFORM_ROTATE);
        }

        if (scale_threshold >= 0.01) {
          gesture.trigger(GestureEvent.GESTURE_TRANSFORM_PINCH);
          if (ev.scale < 1) {
            gesture.trigger(GestureEvent.GESTURE_TRANSFORM_PINCH_IN);
          } else {
            gesture.trigger(GestureEvent.GESTURE_TRANSFORM_PINCH_OUT);
          }
        }

      case GestureEvent.GESTURE_END:
        if (this.triggered) {
          gesture.triggered = gesture.trigger(GestureEvent.GESTURE_TRANSFORM_END);
          this.triggered = false;
        }
    }
  }
}
