import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import openfl.Assets;
import vault.left.Scene;
import vault.left.Key;
import vault.left.Left;
import vault.left.View;
import vault.Vec2;
import vault.algo.Catmull;

class TestView extends View {
  var im: vault.left.View.Image;
  public function new() {
    super();
    im = createImage(Assets.getBitmapData("assets/test.png"));
    viewport(100, 100, 0x00FF00, 1.0);
  }

  public function update() {
    draw(im, 100, 50);
    render();
  }
}

class TestScene extends Scene {
  var view: TestView;
  public function new() {
    super();

    view = new TestView();
    addChild(view);
  }

  override public function update() {
    view.update();
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
