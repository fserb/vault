package vault.ugl;

import vault.geom.Vec2;

enum CardLayout {
  STACK(f: Float);
}

class CardGroup extends Entity {
  public var cards: Array<Card>;
  public var layout: CardLayout;
  var baselayer: Int = 0;
  var nextlayer: Int = 0;

  public function new(?a: Dynamic, ?b: Dynamic, ?c: Dynamic, ?d: Dynamic, ?e: Dynamic) {
    cards = [];
    layout = STACK(0);
    super(a,b,c,d,e);
  }

  override public function begin() {
    pos.x = args[0];
    pos.y = args[1];
  }

  public function all(): Array<Card> {
    return cards;
  }

  public function shuffle() {
    vault.Utils.shuffle(cards);
    for (i in 0...cards.length) {
      var c = cards[i];
      c.pos = getPos(i);
      c.innerlayer = c.baseinner = baselayer + i;
    }
  }

  public function top(): Card {
    return (cards.length > 0) ? cards[cards.length-1] : null;
  }

  public function add(c: Card): Vec2 {
    if (c.group == this) return c.pos;
    if (c.group!= null) {
      c.group.cards.remove(c);
    }
    c.group = this;
    cards.push(c);
    return getPos(cards.length - 1);
  }

  function getPos(n: Int): Vec2 {
    return switch(layout) {
      case STACK(f): new Vec2(pos.x, pos.y - n*f);
      default: pos.copy();
    }
  }

  override public function update() {
    for (i in 0...cards.length) {
      var c = cards[i];
      if (c.moving) continue;
      c.pos = getPos(i);
      c.innerlayer = c.baseinner = baselayer + i;
    }
  }
}
