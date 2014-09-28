package vault.left;

import flash.display.Sprite;
import vault.left.Group;
import vault.Vec2;

/*
A View represents a view into the object space where all objects will be drawn to.
Since it exists both on the world space and on the display space, it contains values
for both sites.
sprite values are display space.
pos, width, height are world space.
*/
class View {
  // world space coordinates of the View:
  public var pos: Vec2;
  public var width: Int;
  public var height: Int;

  public var sprite: Sprite;

  public function new(width:Int = 0, height:Int = 0) {
    sprite = new Sprite();
    sprite.x = sprite.y = 0;
    pos = Vec2.make(0, 0);
    this.width = width;
    this.height = height;
  }

  public function render(scene: Group) {
    sprite.graphics.clear();
    sprite.graphics.beginFill(0x000000, 1.0);
    sprite.graphics.drawRect(0, 0, width, height);
    sprite.graphics.endFill();
    scene.draw(this);

    // TODO: finalize render
  }
}
