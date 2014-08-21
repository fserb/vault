package vault.ugl;

enum GameState {
  TITLE;
  GAME;
  PAUSE;
  FINAL;
}

class Micro extends Scene {
  static var baseColor: Int = 0xFFFFFF;

  var holdback: Float;

  var title: List<Entity>;
  var _title: String;
  var _version: String;

  var paused(default, set): Bool;
  var state(default, set): GameState;

  function begin() {}
  function update() {}
  function end() {}
  function finalupdate() {}

  function final() {
    Game.clear();
    makeTitle();
    state = TITLE;
    Game.mouse.clear();
    Game.key.clear();
  }

  function set_state(s: GameState): GameState {
    state = s;
    // clear input.
    Game.mouse.clear();
    Game.key.clear();
    return s;
  }

  function endGame() {
    if (state != GAME) return;

    holdback = 1.0;
    end();

    state = FINAL;
    final();
  }

  function beginGame() {
    Game.mouse.update();
    Game.key.update();

    Game.totalTime = 0;
    Game.clear();
    begin();
  }

  function makeTitle() {
    title = new List<Entity>();
    var s = 3;
    if (_title.length <= 20) s = 4;
    if (_title.length <= 15) s = 5;

    title.add(new Text().color(baseColor).xy(Game.width/2, Game.height/2).text(_title).size(s));
    title.add(new Text().color(baseColor).xy(Game.width/2, Game.height/1.6).text(_version).size(2));
    title.add(new Text().color(baseColor).xy(Game.width/2, Game.height-10).text("click to begin").align(BOTTOM_CENTER).size(1));
  }

  function set_paused(value: Bool): Bool {
    if (value) {
      if (!state.match(PAUSE)) {
        state = PAUSE;
        title = new List<Entity>();
        var txt = new Text().color(baseColor).text("paused").xy(Game.width/2, Game.height/2).size(3);
        title.add(txt);
        txt._update();
      }
    } else {
      if (state.match(PAUSE)) {
        state = GAME;
        title.pop().remove();
      }
    }
    paused = value;
    return value;
  }

  static public function flash(color: UInt, ?t: Float = 0.01) {
    new Flasher(color, t);
  }

  public function new(title: String, version: String) {
    super();
    _title = title;
    _version = version;

    #if flash
    haxe.Log.setColor(baseColor);
    #end

    new Game(this);
  }

  override public function onBegin() {
    #if ugldebug
      state = GAME;
    #else
      state = TITLE;
    #end

    if (state == TITLE) {
      makeTitle();
    } else {
      beginGame();
    }
  }

  override public function onFrame() {
    // M key for mute.
    if (Game.key.mute_pressed) {
      Sound.mute = !Sound.mute;
    }

    switch (state) {
      case TITLE:
        if (Game.key.any_pressed) {
          state = GAME;
          Game.clear();
          beginGame();
        }
      case GAME:
        update();
        if (Game.key.pause_pressed) {
          paused = true;
        }
      case PAUSE:
        if (Game.key.any_pressed) {
          paused = false;
        }
        Game.totalTime -= Game.time;
        return;
      case FINAL:
        finalupdate();
        holdback = Math.max(0.0, holdback - Game._time);
        if (holdback == 0.0 && Game.key.any_pressed) {
          Game.clear();
          makeTitle();
          state = TITLE;
        }
    }

    if (Game.key.esc_pressed) {
      Game.scene = this;
      endGame();
    }
  }

  override public function onBackground() {
    if (state.match(GAME)) {
      paused = true;
    }
  }
}

class Flasher extends Entity {
  static var layer = 99999;
  var duration = 0.0;
  override public function begin() {
    duration = args[1];
    alignment = TOPLEFT;
    pos.x = pos.y = 0;
    gfx.fill(args[0]).rect(0, 0, Game.width, Game.height);
  }

  override public function update() {
    if (ticks >= duration) remove();
  }
}
