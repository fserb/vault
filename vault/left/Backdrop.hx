package vault.left;

import vault.Vec2;

class Backdrop extends Object {
  public var pos: Vec2;
  public var image: Image;
  public var scrollfactor: Vec2;
  public var repeatx: Bool;
  public var repeaty: Bool;
  public function new(image: Image, scrollx: Float = 1.0, scrolly: Float = 1.0,
    repeatx: Bool = true, repeaty: Bool = true) {
    this.image = image;
    scrollfactor = Vec2.make(scrollx, scrolly);
    pos = Vec2.make(0, 0);
    this.repeatx = repeatx;
    this.repeaty = repeaty;
  }

  override public function render(view: View) {
    var startx = Std.int(Math.floor((view.pos.x*scrollfactor.x - pos.x)/image.width));
    var starty = Std.int(Math.floor((view.pos.y*scrollfactor.y - pos.y)/image.height));
    var endx = startx + Std.int(Math.ceil(view.width/image.width)) + 2;
    var endy = starty + Std.int(Math.ceil(view.height/image.height)) + 2;

    var posx = Std.int(Math.floor(pos.x + startx*image.width - view.pos.x*scrollfactor.x));
    var posy = Std.int(Math.floor(pos.y + starty*image.height - view.pos.y*scrollfactor.y));

    var dy = posy;
    for (y in starty...endy) {
      var dx = posx;
      if (!repeaty && y != 0) continue;
      for (x in startx...endx) {
        if (!repeatx && x != 0) continue;
        view.draw(image, dx, dy);
        dx += image.width;
      }
      dy += image.height;
    }
  }
}
