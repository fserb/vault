import flash.display.BitmapData;
import flash.geom.Rectangle;
import openfl.Assets;
import vault.left.Backdrop;
import vault.left.Game;
import vault.left.Group;
import vault.left.Image;
import vault.left.Key;
import vault.left.Object;
import vault.left.Sprite;
import vault.left.Tilemap;
import vault.left.View;
import vault.left.Left;
import vault.Vec2;
import vault.algo.Catmull;

class X extends Sprite {
  public function new() {
    super();
    image= Image.create(Assets.getBitmapData("assets/test.png"));
    pos.x = 400;
    pos.y = 300;
  }
}

class TestScene extends Group {
  public function new() {
    super();
    add(new X());
  }

  override public function update() {
    super.update();
    if (Left.key.just(Key.R)) {
      Left.game.setScene(function() return new TestScene());
    }
  }
}

class TestGame extends Game {
  public function new() {
    super();
    setScene(function() return new TestScene());
  }

  public static function main() {
    new TestGame();
  }
}
