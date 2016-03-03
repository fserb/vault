package vault.left;

import flash.display.BitmapData;
import openfl.Assets;
import vault.left.Tile;
import flash.events.Event;
import flash.Lib;

class Sprite extends Bitmap {
  var tile: Tile;

  public function new(name: String, scale: Float = 1.0, x: Float = 0.0, y: Float = 0.0) {
    super();
    // tile = new Tile(name);

    scaleX = scaleY = scale;
    this.x = x;
    this.y = y;

    // addChild(new Bitmap(bitmapdata));
  }
}
