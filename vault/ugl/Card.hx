package vault.ugl;

import flash.display.Bitmap;
import flash.display.Sprite;
import vault.geom.Vec2;
import vault.Ease;

using lambda;

/*
TODO:
  - drag&drop
  - proper "stack" of cards
  - proper card "areas"

*/

class Card extends Entity {
  static var nextlayer: Int = 1000;
  public var tags: Array<String>;
  public var group: CardGroup = null;

  public var moving: Bool = false;

  public var popup(default, set): Bool = false;
  public var facing(get, set): Bool;
  var _facing: Bool = false;

  public var highlight: Bool = false;
  public var select: Bool = false;

  var flipangle = -1.0;
  var baseZoom: Float = 1.0;

  var cardSprite: Sprite;
  var cardFront: Bitmap;
  var cardBack: Bitmap;
  var cardHighlight: Bitmap;
  var cardSelect: Bitmap;
  var angleError: Float = 0.0;
  var targetAngle: Float = 0.0;
  public var baseinner: Int = 0;

  inline public function tagged(loc: String): Bool {
    return tags.indexOf(loc) != -1;
  }

  override public function begin() {
    group = args[0];
    pos = group.pos.copy();
    angle = targetAngle + EMath.randDelta(angleError);
    tags = [];
    paint();
    addHitBox(Rect(0, 0, cardFront.width, cardFront.height));
    cardSprite = new Sprite();
    cardSprite.addChild(cardHighlight);
    cardSprite.addChild(cardFront);
    cardSprite.addChild(cardBack);
    cardSprite.addChild(cardSelect);
    sprite.addChild(cardSprite);
    draw();
  }

  public function moveTo(g: CardGroup, d: Float=0.0, f: Null<Bool>=null) {
    var length = g.pos.distance(pos).length;


    var duration = length/1500.0;

    g.add(this);
    moving = true;
    Act.obj(this)
      .delay(d)
      .set("innerlayer", nextlayer++)
      .attr("pos.x", g.pos.x, duration, Ease.quadOut)
      .attr("pos.y", g.pos.y, duration, Ease.quadOut);

    if (f != null && f != _facing) {
      Act.obj(this)
        .attr("flipangle", f ? 1.0 : -1.0, duration, Ease.linear)
        .tween(function(t) {
          if (t == 1.0) {
            angle = targetAngle + EMath.randDelta(angleError);
          }
        }, duration/2.0);
      _facing = f;
    }

    Act.obj(this).set("moving", false).set("innerlayer", baseinner);
  }

  public function set_popup(v: Bool): Bool {
    if (popup == v) return popup;
    popup = v;
    Act.obj(this).attr("baseZoom", popup ? 1.25 : 1.0, 0.2, Ease.quadIn);
    return popup;
  }

  public function get_facing(): Bool {
    return _facing;
  }

  public function set_facing(v: Bool): Bool {
    if (_facing == v) return _facing;
    _facing = v;
    var duration = 0.4;
    moving = true;
    Act.obj(this)
      .set("innerlayer", nextlayer++)
      .attr("flipangle", v ? 1.0 : -1.0, duration, Ease.linear)
      .tween(function(t) {
        if (t == 1.0) {
          angle = targetAngle + EMath.randDelta(angleError);
        }
      }, duration/2.0)
      .set("moving", false)
      .set("innerlayer", baseinner);
    return _facing;
  }

  public function panTo(d: Vec2, s: Float = 1.0, d: Float=0.0) {
  }

  function paint() { }
  function touch() { }

  function draw() {
    cardHighlight.visible = highlight;
    cardSelect.visible = select;
    cardFront.visible = (flipangle >= 0.0);
    cardBack.visible = (flipangle < 0.0);

    cardSprite.scaleX = baseZoom*Ease.quadInOut(Math.abs(flipangle));
    cardSprite.scaleY = baseZoom;
    cardSprite.y = -15.0*Ease.quadInOut(1.0 - Math.abs(flipangle));
  }

  override public function update() {
    if (!moving) {
      for (t in Game.touch.press) {
        if (hitPoint(t.x, t.y)) {
          touch();
        }
      }
    }

    draw();
  }
}
