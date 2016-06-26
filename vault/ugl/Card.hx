package vault.ugl;

import flash.display.Bitmap;
import flash.display.Sprite;
import vault.geom.Vec2;

// assumed size: 90x130
// TODO:
//   - variable size
//   - drag&drop
//   - proper "stack" of cards
//   - proper card "areas"


class Card extends Entity {
  static var nextlayer: Int = 1000;
  public var tags: Array<String>;
  public var highlight: Bool = false;
  public var select: Bool = false;
  public var facing: Bool = false;
  public var moving: Bool = false;
  public var popup: Bool = false;

  var flipangle = -1.0;
  var baseZoom: Float = 1.0;
  var origPos: Vec2 = null;
  var targetPos: Vec2 = null;
  var curTime: Float = 0.0;
  var moveTime: Float = 0.0;
  var cardSprite: Sprite;
  var cardFront: Bitmap;
  var cardBack: Bitmap;
  var cardHighlight: Bitmap;
  var cardSelect: Bitmap;
  var angleError: Float = 0.0;
  var targetAngle: Float = 0.0;
  public var baseinner: Int = 0;

  static var allcards: Array<Card> = null;

  static public function staticReset() {
    allcards = [];
    nextlayer = 1000;
  }

  inline public function tagged(loc: String): Bool {
    return tags.indexOf(loc) != -1;
  }

  static public function getOneOn(loc: String = null): Card {
    if (loc == null) {
      return Card.allcards[0];
    }
    for (c in Card.allcards) {
      if (c.tagged(loc)) {
        return c;
      }
    }
    return null;
  }

  static public function getOn(loc: String = null): Array<Card> {
    if (loc == null) {
      return Card.allcards.copy();
    }
    var r = new Array<Card>();
    for (c in Card.allcards) {
      if (c.tagged(loc)) {
        r.push(c);
      }
    }
    return r;
  }

  override public function begin() {
    if (Card.allcards == null) {
      Card.allcards = [];
    }
    Card.allcards.push(this);
    pos.x = args[0];
    pos.y = args[1];
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

  public function moveTo(x: Float, y: Float, s: Float = 1.0, d: Float=0.0) {
    origPos = pos.copy();
    targetPos = new Vec2(x - pos.x, y - pos.y);
    moveTime = targetPos.length/(s*500);
    curTime = -d;
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
    for (t in Game.touch.press) {
      if (hitPoint(t.x, t.y)) {
        touch();
      }
    }

    var tz = popup ? 1.3 : 1.0;
    baseZoom += EMath.clamp(tz - baseZoom, -2.0*Game.time, 2.0*Game.time);

    if (targetPos != null) {
      if (curTime < 0 && -curTime < Game.time) {
        innerlayer = nextlayer++;
      }
      curTime += Game.time;
      var t = EMath.clamp(curTime/moveTime, 0.0, 1.0);
      pos.x = origPos.x + t*targetPos.x;
      pos.y = origPos.y + t*targetPos.y;
      moving = true;
      if (t == 1.0) {
        moving = false;
        targetPos = null;
        curTime = 0.0;
        innerlayer = baseinner;
      }
    }

    if (targetPos == null) {
      var target = facing ? 1.0 : -1.0;
      var dt = Game.time*5.0;
      var of = flipangle;
      flipangle += EMath.clamp(target - flipangle, -dt, dt);
      if (of*flipangle < 0) {
        angle = targetAngle + EMath.randDelta(angleError);
      }
      moving = (target != flipangle);
      innerlayer = moving ? nextlayer++ : baseinner;
    }

    draw();
  }
}
