package vault.geom;

import vault.geom.Point;

class Rect {
  public var x: Int;
  public var y: Int;
  public var width: Int;
  public var height: Int;

  public var left(get, set): Int;
  public var right(get, set): Int;
  public var top(get, set): Int;
  public var bottom(get, set): Int;

  public function new(x: Int, y: Int, width: Int, height: Int) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  public function copy(): Rect {
    return new Rect(x, y, width, height);
  }

  public inline function contains(px: Int, py: Int): Bool {
    return (px >= x && px < x + width &&
            py >= y && py < y + height);
  }

  public function isEmpty(): Bool {
    return this.width <= 0 || this.height <= 0;
  }

  public function intersection(to: Rect): Rect {
		var x0 = x < to.x ? to.x : x;
		var x1 = right > to.right ? to.right : right;
		if (x1 <= x0) {
			return new Rect(0, 0, 0, 0);
		}

		var y0 = y < to.y ? to.y : y;
		var y1 = bottom > to.bottom ? to.bottom : bottom;
		if (y1 <= y0) {
			return new Rect(0, 0, 0, 0);
		}

		return new Rect(x0, y0, x1 - x0, y1 - y0);
  }

  public inline function include(px: Int, py: Int) {
    if (px < left) left = px;
    if (py < top) top = py;
    if (px > right) right = px;
    if (py > bottom) bottom = py;
  }

  public inline function offset(dx: Int, dy: Int) {
    x += dx;
    y += dy;
  }

  inline function get_left(): Int {
    return x;
  }
  inline function set_left(v: Int): Int {
    width -= v - x;
    x = v;
    return v;
  }

  inline function get_top(): Int {
    return y;
  }
  inline function set_top(v: Int): Int {
    height -= v - y;
    y = v;
    return v;
  }

  inline function get_right(): Int {
    return x + width;
  }
  inline function set_right(v: Int): Int {
    width = v - x;
    return v;
  }

  inline function get_bottom(): Int {
    return y + height;
  }
  inline function set_bottom(v: Int): Int {
    height = v - y;
    return v;
  }

  public function toString(): String {
    return "Rect(" + x + ", " + y + " - " + width + ", " + height + ")";
  }
}
