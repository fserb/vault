package vault.ugl;

import flash.display.Bitmap;
import flash.display.BitmapData;

class MotionScene extends Scene {
  public var motion: Motion;
  public var frames: Array<Bitmap>;
  var step: Float;

  public function new(motion: Motion) {
    super();
    new Game(this);
    frames = new Array<Bitmap>();
    this.motion = motion;
  }

  override public function onFrame() {
    step += Game.time;
    if (step < 1.0/motion.fps) {
      return true;
    }
    step = 0.0;
    if (motion.total > 1) {
      motion.frame = (motion.frame + 1) % motion.total;
      motion.frac = motion.frame / (motion.total - 1);
    } else {
      motion.frame += 1;
      motion.frac = motion.frame;
    }
    return true;
  }

  override public function onEndFrame() {
    if (motion.replay) return;
    var bd = new BitmapData(Game.width, Game.height);
    bd.draw(Game.sprite);

    while (motion.frame > frames.length) {
      frames.push(null);
    }
    var bmp = new Bitmap(bd);
    frames.insert(motion.frame, bmp);

    if (motion.frame == motion.total - 1) {
      motion.remove();
      motion = new MotionReplay(motion.fps, frames);
    }
  }
}

class Motion extends Entity {
  public var frame: Int = -1;
  public var total: Int = 0;
  public var frac: Float = 0.0;
  public var fps: Float = 30.0;
  public var replay: Bool = false;

  public function new() {
    if (Game.scene == null) {
      new MotionScene(this);
    }
    super();
    pos.x = pos.y = 0;
    alignment = TOPLEFT;
  }
}

class MotionReplay extends Motion {
  var frames: Array<Bitmap>;
  override public function new(fps: Float, frames: Array<Bitmap>) {
    super();
    this.fps = fps;
    this.frames = frames;
    this.replay = true;
    this.total = frames.length;
  }

  override public function begin() {

  }

  override public function update() {
    sprite.removeChildAt(0);
    sprite.addChild(frames[frame]);

  }
}
