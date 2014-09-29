import flash.display.BitmapData;
import flash.geom.Rectangle;
import vault.left.Game;
import vault.left.Group;
import vault.left.Image;
import vault.left.Key;
import vault.left.Object;
import vault.left.Sprite;
import vault.left.View;
import vault.left.Left;

class TestObject extends Object {
  var img: Image;
  var img2: Image;
  var img3: Image;
  public function new() {
    var bmd = new BitmapData(100, 100);
    bmd.fillRect(bmd.rect, 0xFFFFFF00);
    img = Image.loadBitmapData(bmd);
    bmd = new BitmapData(100, 100);
    bmd.fillRect(bmd.rect, 0xFF00FFFF);
    img2 = Image.loadBitmapData(bmd);
    bmd = new BitmapData(100, 100);
    bmd.fillRect(new Rectangle(0, 0, 50, 50), 0xFFFF0000);
    bmd.fillRect(new Rectangle(50, 0, 50, 50), 0xFF00FF00);
    bmd.fillRect(new Rectangle(0, 50, 50, 50), 0xFF0000FF);
    bmd.fillRect(new Rectangle(50, 50, 50, 50), 0xFFFFFFFF);
    img3 = Image.loadTiledBitmap(bmd, 50, 50);
  }
  var s = 0;
  override public function draw(view: View) {
    view.draw(img, Left.width/2, Left.height/2, Math.PI*2*s/1000);
    view.draw(img, 50, 50, -Math.PI*2*s/1000, 0.5);
    view.draw(img2, Left.width/2 + 300*Math.cos(2*Math.PI*s/300),
      Left.height/2 + 300*Math.sin(2*Math.PI*s/300));
    view.draw(img2, Left.width/2 + 300*Math.cos(Math.PI + 2*Math.PI*s/300),
      Left.height/2 + 300*Math.sin(Math.PI + 2*Math.PI*s/300));
    view.draw(img, 700, 400, -Math.PI*2*s/1000, 0.5);

    view.draw(img3[0], 100, 50);
    view.draw(img3[1], 200, 50);
    view.draw(img3[2], 300, 50);
    view.draw(img3[3], 400, 50);

    s++;
  }
}

class TestSprite extends Sprite {
  public function new() {
    super();
    var bmd = new BitmapData(80, 80);
    bmd.fillRect(bmd.rect, 0xFFFFFFFF);
    image = Image.loadBitmapData(bmd);
    pos.x = pos.y = 300;
  }

  override public function update() {
    angle += Left.elapsed*2*Math.PI/10;
  }
}


class SecondSprite extends Sprite {
  public function new() {
    super();
    var bmd = new BitmapData(40, 40);
    bmd.fillRect(bmd.rect, 0xFFFF0000);
    image = Image.loadBitmapData(bmd);
    pos.x = pos.y = 400;
  }

  override public function update() {
    if (Left.key.pressed(Key.LEFT)) { pos.x -= Left.elapsed*150; }
    if (Left.key.pressed(Key.RIGHT)) { pos.x += Left.elapsed*150; }
    if (Left.key.pressed(Key.UP)) { pos.y -= Left.elapsed*150; }
    if (Left.key.pressed(Key.DOWN)) { pos.y += Left.elapsed*150; }

  }
}

class TestScene extends Group {
  public function new() {
    super();
    // add(new TestObject());
    add(new TestSprite());
    add(new SecondSprite());
    var v = new View();
    v.scale = 0.3;
    v.sprite.x = 550;
    v.sprite.y = 300;
    Left.game.addView(v);
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
