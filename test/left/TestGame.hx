import vault.left.Game;
import vault.left.Group;
import vault.left.Image;
import vault.left.Object;
import vault.left.View;
import vault.left.Left;

class TestObject extends Object {
  var img: Image;
  var img2: Image;
  public function new() {
    var bmd = new flash.display.BitmapData(100, 100);
    bmd.fillRect(bmd.rect, 0xFFFF0000);
    img = Image.loadBitmapData(bmd);
    bmd = new flash.display.BitmapData(100, 100);
    bmd.fillRect(bmd.rect, 0xFF0000FF);
    img2 = Image.loadBitmapData(bmd);
  }
  var s = 0;
  override public function draw(view: View) {
    // for (i in 0...1000) {
    view.draw(img, Left.width/2, Left.height/2, Math.PI*2*s/1000);
    view.draw(img2, Left.width/2 + 200*Math.cos(2*Math.PI*s/300),
      Left.height/2 + 200*Math.sin(2*Math.PI*s/300));
    // }
    s++;
  }
}

class TestScene extends Group {
  public function new() {
    super();
    add(new TestObject());
  }
}

class TestGame extends Game {
  public function new() {
    super(new TestScene());
  }

  public static function main() {
    new TestGame();
  }
}
