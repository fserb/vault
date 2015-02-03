package vault.ugl;

import vault.Sfxr;
import vault.SfxrParams;

class Sound {
  static public var mute = false;

  var sfxr: Sfxr = null;
  var name: String = null;
  var params: SfxrParams;
  static var soundbank = new Map<String, Sfxr>();

  public function new(name: String) {
    this.name = name;
    if (this.name != "" && soundbank.exists(name)) {
      sfxr = soundbank[name];
    } else {
      sfxr = null;
    }
    params = new SfxrParams();
    vol(0.2);
  }

  public function str(s: String): Sound {
    params = SfxrParams.fromString(s);
    return this;
  }

  function load(): Sound {
    if (sfxr != null) return this;
    sfxr = new Sfxr(params);
    if (name != null) soundbank[name] = sfxr;
    return this;
  }

  public function coin(?seed: Null<Int> = null): Sound { params.seed(seed); params.generatePickupCoin(); load(); return this; }
  public function laser(?seed: Null<Int> = null): Sound { params.seed(seed); params.generateLaserShoot(); load(); return this; }
  public function explosion(?seed: Null<Int> = null): Sound { params.seed(seed); params.generateExplosion(); load(); return this; }
  public function powerup(?seed: Null<Int> = null): Sound { params.seed(seed); params.generatePowerup(); load(); return this; }
  public function hit(?seed: Null<Int> = null): Sound { params.seed(seed); params.generateHitHurt(); load(); return this; }
  public function jump(?seed: Null<Int> = null): Sound { params.seed(seed); params.generateJump(); load(); return this; }
  public function blip(?seed: Null<Int> = null): Sound { params.seed(seed); params.generateBlipSelect(); load(); return this; }

  public function vol(v: Float): Sound { params.masterVolume = v*2.0; return this; }

  public function play() {
    load();
    if (!Sound.mute) {
      sfxr.play();
    }
  }
}
