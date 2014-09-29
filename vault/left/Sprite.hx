package vault.left;

import flash.geom.Rectangle;
import vault.Vec2;

class Sprite extends Object {
  var pos: Vec2;
  var scale: Float = 1.0;
  var angle: Float = 0.0;

  var image: Image = null;
  var frame: Int = -1;

  public function new() {
    pos = Vec2.make(0, 0);
  }

  override public function draw(view: View) {
    if (image == null) return;
    if (frame == -1) {
      view.draw(image, pos.x, pos.y, angle, scale);
    } else {
      view.draw(image[frame], pos.x, pos.y, angle, scale);
    }
  }

  // returns true if colliding with @target.
  // It does a pixel perfect collision.
  public function collide(target: Sprite): Bool {
    // 1. Big BB collision considering rotation
    var aDiag = Vec2.make(this.image.width/2, this.image.height/2).length;
    var aBB = new Rectangle(this.pos.x - aDiag, this.pos.y -aDiag, aDiag*2, aDiag*2);
    var bDiag = Vec2.make(target.image.width/2, target.image.height/2).length;
    var bBB = new Rectangle(target.pos.x - bDiag, target.pos.y -bDiag, bDiag*2, bDiag*2);

    var intersect = aBB.intersection(bBB);
    if (intersect.width <= 0) {
      return false;
    }
    return false;
    // 2. Small BB collision considering rotation


    // 3. Pixel perfect collision

  }
}
