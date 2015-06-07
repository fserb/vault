import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import openfl.Assets;
import vault.Ease;
import vault.Extra;
import vault.left.Particles;
import vault.left.Scene;
import vault.left.Key;
import vault.left.Left;
import vault.left.Text;
import vault.left.View;
import vault.Vec2;
import vault.algo.Catmull;
import vault.Act;

class TestScene extends Scene {
  var ps: Particles;
  public function new() {
    super();

    ps = new Particles("assets/test.json");
    addChild(ps);

    ps.start(new Vec2(400, 300));
  }

  override public function update() {
    super.update();
  }
}

class TestGame {
  public static function main() {
    Left.setScene(function() return new TestScene());
  }
}
