import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import openfl.Assets;
import vault.Extra;
import vault.left.Scene;
import vault.left.Key;
import vault.left.Left;
import vault.left.View;
import vault.Vec2;
import vault.algo.Catmull;

class A extends Sprite {
  public function new() {
    super();
    graphics.beginFill(0xFF0000);
    graphics.drawRect(0, 0, 100, 100);
  }
}
class B extends Sprite {
  public function new() {
    super();
    graphics.beginFill(0x00FF00);
    graphics.drawRect(75, 75, 100, 100);
  }
}
class C extends Sprite {
  public function new() {
    super();
    graphics.beginFill(0x0000FF);
    graphics.drawRect(150, 150, 100, 100);
  }
}

class TestScene extends Scene {
  public function new() {
    super();

    addChild(new A());
    addChild(new B());
    addChild(new C());
  }

  override public function update() {
    super.update();
    if (Left.key.just(Key.R)) {
      Left.setScene(function() return new TestScene());
    }
  }
}

class TestGame {
  public static function main() {
    Left.setScene(function() return new TestScene());
  }
}
