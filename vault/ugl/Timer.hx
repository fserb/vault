package vault.ugl;

class Timer extends Entity {
  var _every: Float;
  var _delay: Float;
  var _func: List<Void->Bool>;
  public function new() {
    super();
    _every = 0.0;
    _delay = 0.0;
    _func = new List<Void->Bool>();
  }

  public function every(v: Float): Timer { _every = v; return this; }
  public function delay(v: Float): Timer {
    if (_delay > 0.0)
      run(function () {
        ticks = 0;
        _delay = v;
        return false;
      });
    else
      _delay = v;
    return this;
  }

  public function run(f: Void->Bool): Timer {
    _func.add(f);
    return this;
  }

  override public function update() {
    if (_delay > 0.0) {
      if (ticks >= _delay) {
        //ticks = 0;
        _func.pop()();
      }
    } else {
      if (ticks >= _every) {
        ticks -= _every;
        var f = _func.first();
        if (!f()) {
          _func.pop();
        }
      }
    }
    if (_func.length == 0) {
      remove();
    }
  }
}
