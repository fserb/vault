package vault.ugl;

import vault.Sfxr;
import vault.SfxrParams;

class Sound {
  var sfxr: Sfxr = null;
  var params: SfxrParams;

  public function new(?seed: Null<Int> = null) {
    params = new SfxrParams(seed);
    vol(0.2);
  }

  public function str(s: String): Sound {
    params = SfxrParams.fromString(s);
    return this;
  }

  public function coin(): Sound { params.generatePickupCoin(); return this; }
  public function laser(): Sound { params.generateLaserShoot(); return this; }
  public function explosion(): Sound { params.generateExplosion(); return this; }
  public function powerup(): Sound { params.generatePowerup(); return this; }
  public function hit(): Sound { params.generateHitHurt(); return this; }
  public function jump(): Sound { params.generateJump(); return this; }
  public function blip(): Sound { params.generateBlipSelect(); return this; }

  public function vol(v: Float): Sound { params.masterVolume = v; return this; }

  public function mutate(?r:Float = 0.05): Sound { params.mutate(r); return this; }

  public function play() {
    if (sfxr == null) {
      sfxr = new Sfxr(params);
    }
    sfxr.play();
  }
}
