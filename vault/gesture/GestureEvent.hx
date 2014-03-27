package vault.gesture;

import flash.events.Event;

enum Direction {
  UP;
  DOWN;
  LEFT;
  RIGHT;
}

class GestureEvent extends Event {
  public static var GESTURE_BEGIN = "gestureBegin";
  public static var GESTURE_MOVE = "gestureMove";
  public static var GESTURE_END = "gestureEnd";

  public static var GESTURE_TAP = "gestureTap";
  public static var GESTURE_TAP_1 = "gestureTap1";
  public static var GESTURE_TAP_2 = "gestureTap2";
  public static var GESTURE_TAP_3 = "gestureTap3";
  public static var GESTURE_TAP_4 = "gestureTap4";
  public static var GESTURE_TAP_5 = "gestureTap5";


  public static var GESTURE_SWIPE = "gestureSwipe";
  public static var GESTURE_SWIPE_UP = "gestureSwipeUP";
  public static var GESTURE_SWIPE_DOWN = "gestureSwipeDOWN";
  public static var GESTURE_SWIPE_LEFT = "gestureSwipeLEFT";
  public static var GESTURE_SWIPE_RIGHT = "gestureSwipeRIGHT";

  public static var GESTURE_TRANSFORM_BEGIN = "gestureTransformBegin";
  public static var GESTURE_TRANSFORM_MOVE = "gestureTransformMove";
  public static var GESTURE_TRANSFORM_END = "gestureTransformEnd";

  public static var GESTURE_TRANSFORM_ROTATE = "gestureTransformRotate";
  public static var GESTURE_TRANSFORM_PINCH = "gestureTransformPinch";
  public static var GESTURE_TRANSFORM_PINCH_IN = "gestureTransformPinchIn";
  public static var GESTURE_TRANSFORM_PINCH_OUT = "gestureTransformPinchOut";

  public static var GESTURE_DRAG_BEGIN = "gestureDragBegin";
  public static var GESTURE_DRAG_MOVE = "gestureDragMove";
  public static var GESTURE_DRAG_END = "gestureDragEnd";

  public static var GESTURE_HOLD = "gestureHold";


  public var initial: GestureEvent;
  public var fullTouches: Array<Vec2>;
  public var timestamp: Float;
  public var touches: Array<Vec2>;

  public var center: Vec2;
  public var deltaTime: Float;
  public var delta: Vec2;
  public var velocity: Vec2;

  public var direction: Direction;
  public var scale: Float;
  public var rotation: Float;

  public var stageX: Float;
  public var stageY: Float;

  public function new(type: String, touches: Map<Int, Vec2>, prev: GestureEvent) {
    super(type);

    this.touches = new Array<Vec2>();

    var keys = new Array<Int>();
    for (k in touches.keys()) {
      keys.push(k);
    }
    keys.sort(function(a, b) { if (a > b) return -1; else if (a < b) return 1; else return 0; });
    for (k in keys) {
      this.touches.push(touches[k]);
    }

    this.fullTouches = this.touches;

    if (prev == null || this.touches.length > prev.initial.touches.length) {
      this.initial = this;
    } else {
      this.initial = prev.initial;
      if (prev.fullTouches.length > this.fullTouches.length) {
        this.fullTouches = prev.fullTouches;
      }
    }

    this.timestamp = flash.Lib.getTimer()/1000.0;

    calculateMetrics();
  }

  function calculateMetrics() {
    // center.
    var minp = new Vec2(1e99, 1e99);
    var maxp = new Vec2(-1e99, -1e99);
    for (t in fullTouches) {
      minp.x = Math.min(minp.x, t.x);
      minp.y = Math.min(minp.y, t.y);
      maxp.x = Math.max(maxp.x, t.x);
      maxp.y = Math.max(maxp.y, t.y);
    }
    if (fullTouches.length > 0) {
      this.center = new Vec2((minp.x + maxp.x)/2.0, (minp.y + maxp.y)/2.0);
    } else {
      this.center = new Vec2(0, 0);
    }

    this.deltaTime = this.timestamp - initial.timestamp;

    this.delta = new Vec2(this.center.x - initial.center.x,
                          this.center.y - initial.center.y);

    if (this.deltaTime > 0) {
      this.velocity = new Vec2(this.delta.x / this.deltaTime,
                               this.delta.y / this.deltaTime);
    } else {
      this.velocity = new Vec2(0, 0);
    }

    if (Math.abs(delta.x) >= Math.abs(delta.y)) {
      if (delta.x >= 0) {
        this.direction = RIGHT;
      } else {
        this.direction = LEFT;
      }
    } else {
      if (delta.y >= 0) {
        this.direction = DOWN;
      } else {
        this.direction = UP;
      }
    }

    // scale, rotation
    if (fullTouches.length >= 2 && initial.fullTouches.length >= 2) {
      var e = new Vec2(fullTouches[1].x - fullTouches[0].x, fullTouches[1].y - fullTouches[0].y);
      var s = new Vec2(initial.fullTouches[1].x - initial.fullTouches[0].x, initial.fullTouches[1].y - initial.touches[0].y);

      this.scale = e.length/s.length;
      this.rotation = e.angle - s.angle;
    } else {
      this.scale = 1;
      this.rotation = 0;
    }
  }

  override public function toString(): String {
    return ("<" + type + " : " + fullTouches + "  C: " + center +
            "  dt: " + deltaTime + "  dC: " + delta.length +
            "  dir: " + direction + "  s: " + scale +
            "  r: " + rotation*180/Math.PI + ">");
  }
}
