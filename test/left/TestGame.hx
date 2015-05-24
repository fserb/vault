import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import openfl.Assets;
import vault.Ease;
import vault.Extra;
import vault.left.Scene;
import vault.left.Key;
import vault.left.Left;
import vault.left.Text;
import vault.left.View;
import vault.Vec2;
import vault.algo.Catmull;
import vault.Act;

class A extends Sprite {
  public function new() {
    super();
    graphics.beginFill(0xFF0000);
    graphics.drawRect(0, 0, 100, 100);

    Act.obj(this).attr("x", 200, 1.0, Ease.quadIn).attr("y", 200);
    Act.obj(this).then().attr("y", 0, 1.0, Ease.quadIn);
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
  var a: A;
  var txt: Text;
  public function new() {
    super();

    a = new A();
    addChild(a);
    addChild(new B());
    addChild(new C());

    txt = new Text("hello", "assets/BebasNeue.otf", 40, 0xFFFFFF);
    addChild(txt);
    txt.x = 200;
    txt.y = 200;
  }

  override public function update() {
    super.update();
    if (Left.key.just(Key.SPACE)) {
      Act.obj(txt).attr('scaleX', 3.0, 2.0).attr('scaleY', 3.0);
    }
    if (Left.key.just(Key.X)) {
      Act.obj(a).resume();
    }
    if (Left.key.just(Key.Z)) {
      Act.obj(a).stop();
    }
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
