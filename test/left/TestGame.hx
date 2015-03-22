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

// class TestObject extends Object {
//   var img: Image;
//   var img2: Image;
//   var img3: Image;
//   public function new() {
//     var bmd = new BitmapData(100, 100);
//     bmd.fillRect(bmd.rect, 0xFFFFFF00);
//     img = Image.loadBitmapData(bmd);
//     bmd = new BitmapData(100, 100);
//     bmd.fillRect(bmd.rect, 0xFF00FFFF);
//     img2 = Image.loadBitmapData(bmd);
//     bmd = new BitmapData(100, 100);
//     bmd.fillRect(new Rectangle(0, 0, 50, 50), 0xFFFF0000);
//     bmd.fillRect(new Rectangle(50, 0, 50, 50), 0xFF00FF00);
//     bmd.fillRect(new Rectangle(0, 50, 50, 50), 0xFF0000FF);
//     bmd.fillRect(new Rectangle(50, 50, 50, 50), 0xFFFFFFFF);
//     img3 = Image.loadTiledBitmap(bmd, 50, 50);
//   }
//   var s = 0;
//   override public function draw(view: View) {
//     view.draw(img, Left.width/2, Left.height/2, Math.PI*2*s/1000);
//     view.draw(img, 50, 50, -Math.PI*2*s/1000, 0.5);
//     view.draw(img2, Left.width/2 + 300*Math.cos(2*Math.PI*s/300),
//       Left.height/2 + 300*Math.sin(2*Math.PI*s/300));
//     view.draw(img2, Left.width/2 + 300*Math.cos(Math.PI + 2*Math.PI*s/300),
//       Left.height/2 + 300*Math.sin(Math.PI + 2*Math.PI*s/300));
//     view.draw(img, 700, 400, -Math.PI*2*s/1000, 0.5);

//     view.draw(img3[0], 100, 50);
//     view.draw(img3[1], 200, 50);
//     view.draw(img3[2], 300, 50);
//     view.draw(img3[3], 400, 50);

//     s++;
//   }
// }

// class TestSprite extends Sprite {
//   public function new() {
//     super();
//     var bmd = new BitmapData(80, 80);
//     bmd.fillRect(bmd.rect, 0xFF0000FF);
//     image = Image.loadBitmapData(bmd);
//     pos.x = pos.y = 300;
//   }

//   override public function update() {
//     angle += Left.elapsed*2*Math.PI/10;

//   }
// }


// class SecondSprite extends Sprite {
//   public function new() {
//     super();
//     image= Image.loadImage("assets/test.png");
//     pos.x = pos.y = 400;
//   }

//   override public function update() {
//     if (Left.key.pressed(Key.LEFT)) { pos.x -= Left.elapsed*100; }
//     if (Left.key.pressed(Key.RIGHT)) { pos.x += Left.elapsed*100; }
//     if (Left.key.pressed(Key.UP)) { pos.y -= Left.elapsed*100; }
//     if (Left.key.pressed(Key.DOWN)) { pos.y += Left.elapsed*100; }

//     var sc: TestScene = cast Left.game.scene;

//     collide(sc.s1);
//   }
// }

// class TestScene extends Group {
//   public var s1: Sprite;
//   public var s2: Sprite;
//   public var map: Tilemap;
//   public function new() {
//     super();
//     // add(new TestObject());

//     var bmd = new BitmapData(150, 100, true, 0);
//     bmd.fillRect(new Rectangle(50, 0, 50, 50), 0xFF00FF00);
//     bmd.fillRect(new Rectangle(100, 0, 50, 50), 0xFFFFFF00);
//     bmd.fillRect(new Rectangle(0, 50, 50, 50), 0xFF0000FF);
//     bmd.fillRect(new Rectangle(50, 50, 50, 50), 0xFFFF0000);
//     bmd.fillRect(new Rectangle(100, 0, 50, 50), 0xFF00FFFF);

//     var data = new Array<Int>();
//     var dim = 20;
//     for (y in 0...dim) {
//       for (x in 0...dim) {
//         var c = Std.int(6*Vec2.make(x - dim/2, y -dim/2).length/10)%6;
//         if (x == 0 || y == 0 || x == dim-1 || y == dim -1) c = 4;
//         data.push(c);
//       }
//     }

//     map = new Tilemap(data, dim, dim, Image.loadTiledBitmap(bmd, 50, 50));
//     s1 = new TestSprite();
//     s2 = new SecondSprite();
//     add(new Backdrop(Image.loadImage("assets/clouds.png"), 0.2, 0.2));
//     add(map);
//     add(s1);
//     add(s2);
//     var v = new View();
//     v.scale = 0.3;
//     v.sprite.x = 550;
//     v.sprite.y = 300;
//     // Left.game.addView(v);
//   }

//   override public function update() {
//     super.update();
//     if (Left.key.pressed(Key.W)) { Left.views[0].pos.y -= Left.elapsed*200; }
//     if (Left.key.pressed(Key.S)) { Left.views[0].pos.y += Left.elapsed*200; }
//     if (Left.key.pressed(Key.A)) { Left.views[0].pos.x -= Left.elapsed*200; }
//     if (Left.key.pressed(Key.D)) { Left.views[0].pos.x += Left.elapsed*200; }

//     // if (Left.key.just(Key.R)) { Left.views[1].scale *= 1.1; }
//     // if (Left.key.just(Key.F)) { Left.views[1].scale /= 1.1; }

//   }
// }

class TestScene2 extends Group {
  public function new() {
    super();
    var d = new Array<Vec2>();
    for (i in 0...10) {
      d.push(Vec2.make(100 + 600*Math.random(), 50 + 300*Math.random()));
    }

    var s = new flash.display.Sprite();
    var gfx = s.graphics;
    Left.views[0].sprite.addChild(s);

    for (p in d) {
      gfx.beginFill(0xFF0000);
      gfx.drawCircle(p.x, p.y, 5);
    }

    var c = new Catmull(d, false);
    gfx.endFill();
    gfx.lineStyle(2, 0x0000FF);
    gfx.moveTo(d[0].x, d[0].y);
    for (t in 0...1001) {
      var r = c.get(t*d.length/1000);
      gfx.lineTo(r.x, r.y);
    }
  }

  override public function update() {
    super.update();
    if (Left.key.just(Key.R)) {
      Left.game.setScene(function() return new TestScene2());
    }
  }
}


class X extends Sprite {
  public function new() {
    super();
    image= Image.create(Assets.getBitmapData("assets/test.png"));
    pos.x = 400;
    pos.y = 300;
  }
}

class TestScene3 extends Group {
  public function new() {
    super();
    add(new X());
  }

  override public function update() {
    super.update();
    if (Left.key.just(Key.R)) {
      Left.game.setScene(function() return new TestScene3());
    }
  }
}

class TestGame extends Game {
  public function new() {
    super();
    setScene(function() return new TestScene3());
  }

  public static function main() {
    new TestGame();
  }
}
