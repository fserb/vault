package vault.left;

import openfl.Assets;

typedef Animation = {
  var name: String;
  var baseimage: Int;
  var frames: Array<Int>;
  var time: Float;
  var looped: Bool;
}

class Anim extends Sprite {
  var animations: Map<String, Animation>;
  var cur: Animation;
  var curFrame: Int;
  var frameTime: Float;

  public function new() {
    super();

    image = Image.createEmpty();
    animations = new Map<String, Animation>();
    cur = {name: null, frames: [], baseimage: -1, time: 0.0, looped: false};
    curFrame = 0;
    frameTime = 0.0;
  }

  override function getImage(): Image {
    if (cur.name == null) return image;
    if (cur.baseimage == -1) {
      return image[cur.frames[curFrame]];
    } else {
      return image[cur.baseimage][cur.frames[curFrame]];
    }
  }

  public function load(name: String, file: String, fps: Float, width: Int, height: Int, looped: Bool) {
    var im = Image.createTiled(Assets.getBitmapData(file), width, height, true);
    image.addImage(im);

    var frames: Array<Int> = [];
    for (i in 0...im.tiles.length) {
      frames.push(i);
    }

    animations[name] = { name: name, frames: frames, baseimage: image.tiles.length-1,
      time: 1.0/fps, looped: looped };
  }

  public function anim(name: String, frames: Array<Int>, fps: Float, looped: Bool) {
    animations[name] = { name: name, frames: frames, baseimage: -1, time: 1.0/fps, looped: looped };
  }

  public function play(name: String = null) {
    if (name != null && cur.name != name) {
      cur = animations[name];
      curFrame = 0;
      frameTime = 0.0;
    } else {
      frameTime += Left.elapsed;
      if (frameTime >= cur.time) {
        frameTime -= cur.time;
        curFrame += 1;
        if (curFrame >= cur.frames.length) {
          if (cur.looped) {
            curFrame = 0;
          } else {
            curFrame = cur.frames.length - 1;
          }
        }
      }
    }
  }
}
