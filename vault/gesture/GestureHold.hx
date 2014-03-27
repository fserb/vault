package vault.gesture;

import vault.gesture.Gesture;
import vault.gesture.Gesture.GestureDetector;
import vault.gesture.GestureEvent;

class GestureHold extends GestureDetector {
  var curEvent: GestureEvent;
  var sent = false;
  var gaveup = false;

  function send(gesture: Gesture) {
    if (gaveup || sent || curEvent.delta.length() > 100 || gesture.triggered != null ||
        curEvent.fullTouches.length > 1) {
      gaveup = true;
      return;
    }
    var delta = (flash.Lib.getTimer()/1000.0) - curEvent.initial.timestamp;
    if (delta >= 0.5) {
      gesture.triggered = gesture.trigger(GestureEvent.GESTURE_HOLD);
      sent = true;
    } else {
      haxe.Timer.delay(function() { send(gesture); }, 500);
    }
  }

  override public function handle(gesture: Gesture, ev: GestureEvent) {
    if (ev.type == GestureEvent.GESTURE_BEGIN) {
      sent = false;
      gaveup = false;
    }
    curEvent = ev;
    send(gesture);
  }
}

