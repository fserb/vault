package vault;

class Range {
  var cur: Float;
  var step: Float;
  var stop: Float;

  public function new(start: Float, stop: Float, step: Float) {
    this.cur = start;
    this.step = step;
    this.stop = stop;
  }

  public function hasNext() {
    return this.cur < this.stop;
  }

  public function next() {
    var c = this.cur;
    this.cur += this.step;
    return c;
  }
}
