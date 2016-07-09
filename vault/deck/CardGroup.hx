package vault.deck;

import vault.geom.Vec2;

enum CardLayout {
  STACK(f: Float);
}

class CardGroup extends Entity {
  public var cards: Array<Card>;
  public var layout: CardLayout;
  var baselayer: Int = 0;
  var nextlayer: Int = 0;

  public function new(x: Float, y: Float) {
    super();
    cards = [];
    layout = STACK(0);
    pos.x = x;
    pos.y = y;
  }

  public function all(): Array<Card> {
    return cards;
  }

  public function shuffle() {
    vault.Utils.shuffle(cards);
    for (i in 0...cards.length) {
      var c = cards[i];
      c.pos = getPos(i);
      c.layer = baselayer + i/100;
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
      c.layer = baselayer + i/100;
    }
  }
}
