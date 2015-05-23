import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import openfl.Assets;
import vault.left.Scene;
import vault.left.Key;
import vault.left.Left;
import vault.Vec2;
import vault.algo.Catmull;

class TestScene extends Scene {
  var s: Bitmap;
  public function new() {
    super();

    s = new Bitmap(Assets.getBitmapData("assets/test.png"));
    addChild(s);
    s.x = 0;
    s.y = 100;
  }

  override public function update() {
    s.x += Left.elapsed*100;

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
