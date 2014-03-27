package vault.ugl;

class Timer extends Entity {
  var _every: Float;
  var _delay: Float;
  var _func: Void->Void;
  var running: Bool;
  public function new() {
    super();
    running = false;
    _every = 0.0;
    _delay = 0.0;
    _func = function() {};
  }

  public function every(v: Float): Timer { _every = v; return this; }
  public function delay(v: Float): Timer { _delay = v; return this; }

  public function run(f: Void->Void): Timer {
    _func = f;
    start();
    return this;
  }

  public function start(): Timer {
    running = true;
    ticks = 0;
    return this;
  }

  public function stop(): Timer {
    running = false;
    return this;
  }

  override public function update() {
    if (!running) return;

    if (_delay > 0.0) {
      _delay -= Game.time;
      if (_delay <= 0) {
        _func();
        remove();
      }
    } else if (_every > 0.0) {
      if (ticks >= _every) {
        ticks -= _every;
        _func();
      }
    }
  }
}
