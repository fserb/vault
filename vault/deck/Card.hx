package vault.deck;

import flash.display.Bitmap;
import flash.display.Sprite;
import vault.geom.Vec2;
import vault.Ease;

using lambda;

/*
TODO:
  - drag&drop
  - group can orientate layout on cards smoothly
  - click distribution
*/

class Card extends Entity {
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

  public function new(g: CardGroup) {
    super();
    pos = g.add(this);
    angle = targetAngle + EMath.randDelta(angleError);
    tags = [];
    paint();
    cardSprite = new Sprite();
    cardSprite.addChild(cardHighlight);
    cardSprite.addChild(cardFront);
    cardSprite.addChild(cardBack);
    cardSprite.addChild(cardSelect);
    sprite.addChild(cardSprite);
    update();
  }

  public function moveTo(g: CardGroup, d: Float=0.0, f: Null<Bool>=null) {
    var length = g.pos.distance(pos).length;

    var duration = length/1500.0;

    var target = g.add(this);
    moving = true;
    Act.obj(this)
      .delay(d)
      .incr("layer", 100)
      .attr("pos.x", target.x, duration, Ease.quadOut)
      .attr("pos.y", target.y, duration, Ease.quadOut);

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

    Act.obj(this).set("moving", false).incr("layer", -100);
  }

  public function set_popup(v: Bool): Bool {
    if (popup == v) return popup;
    popup = v;
    Act.obj(this)
      .incr("layer", 100)
      .attr("baseZoom", popup ? 1.25 : 1.0, 0.2, Ease.quadIn)
      .incr("layer", -100);
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
      .incr("layer", 100)
      .attr("flipangle", v ? 1.0 : -1.0, duration, Ease.linear)
      .tween(function(t) {
        if (t == 1.0) {
          angle = targetAngle + EMath.randDelta(angleError);
        }
      }, duration/2.0)
      .set("moving", false)
      .incr("layer", -100);
    return _facing;
  }

  public function panTo(d: Vec2, s: Float = 1.0, d: Float=0.0) {
  }

  function paint() { }
  function touch() { }

  override public function update() {
    cardHighlight.visible = highlight;
    cardSelect.visible = select;
    cardFront.visible = (flipangle >= 0.0);
    cardBack.visible = (flipangle < 0.0);

    cardSprite.scaleX = baseZoom*Ease.quadInOut(Math.abs(flipangle));
    cardSprite.scaleY = baseZoom;
    cardSprite.x = -cardFront.width*baseZoom/2.0;
    cardSprite.y = -cardFront.height*baseZoom/2.0 -15.0*Ease.quadInOut(1.0 - Math.abs(flipangle));

    rect.x = cardSprite.x;
    rect.y = cardSprite.y;
    rect.width = cardFront.width*baseZoom;
    rect.height = cardFront.height*baseZoom;
  }
}
