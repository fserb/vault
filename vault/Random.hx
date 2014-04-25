// Based on Flambe's implementation:
//   https://github.com/aduros/flambe/blob/master/src/flambe/util/Random.hx

package vault;

/**
 * A seedable, portable random number generator. Fast and random enough for games.
 * http://en.wikipedia.org/wiki/Linear_congruential_generator
 */
class Random {
  private var _state: Int;
  static var MAX_INT: Int = 2147483647;

  public function new (?seed: Int = null) {
    _state = (seed != null) ? seed : Math.floor(Math.random() * MAX_INT);
  }

  /**
   * Returns an integer between >= 0 and < INT_MAX
   */
  public function int(): Int {
    // These constants borrowed from glibc
    // Force float multiplication here to avoid overflow in Flash (and keep parity with JS)
    _state = cast ((1103515245.0*_state + 12345) % MAX_INT);
    return _state;
  }

  /**
   * Returns a number >= 0 and < 1
   */
  public function float (): Float {
    return int() / MAX_INT;
  }

  public function reset (value: Int) {
    _state = value;
  }
}
