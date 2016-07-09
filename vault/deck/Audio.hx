package vault.deck;

import openfl.Assets;
import flash.media.Sound;

class Audio {
  static public var mute = false;

  var name: String = null;
  var snd: Sound = null;
  static var soundbank = new Map<String, Sound>();

  public function new(opts: Array<String>) {
    this.name = opts[Std.int(opts.length*Math.random())];
    if (this.name != "" && soundbank.exists(name)) {
      snd = soundbank[name];
    } else {
      snd = Assets.getSound(name);
    }
  }

  public function play() {
    if (!Audio.mute) {
      snd.play();
    }
  }
}
