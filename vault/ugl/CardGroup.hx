package vault.ugl;

class CardGroup extends Entity {
  public var cards: Array<Card>;
  var baselayer: Int = 0;
  var nextlayer: Int = 0;

  override public function begin() {
    pos.x = args[0];
    pos.y = args[1];
    cards = [];
  }

  public function all(): Array<Card> {
    return cards;
  }

  public function top(): Card {
    return (cards.length > 0) ? cards[cards.length-1] : null;
  }

  public function add(c: Card) {
    if (c.group == this) return;
    c.group.cards.remove(c);
    c.group = this;
    cards.push(c);
  }

  override public function update() {
  }
}
