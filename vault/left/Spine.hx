package vault.left;

import openfl.Assets;
import vault.Point;

typedef SpineAtlas = {
  var xy: Point;
  var size: Point;
}

class Spine extends Sprite {
  var atlas: Map<String, {xy: Point, size: Point}>;

  public function new(basename: String) {
    super();
    atlas = loadAtlas(basename + ".atlas");
    loadSpine(basename = ".json");
  }

  function loadAtlas(filename: String): Map<String, {xy: Point, size: Point}> {
    var ret = new Map<String, {xy: Point, size: Point}>();
    var name = null;
    var image_name = null;

    for (line in Assets.getText(filename).split("\n")) {
      line = StringTools.trim(line);
      if (line.length == 0) continue;
      var sep = line.indexOf(':');

      if (sep == -1) {
        if (image_name == null) {
          image_name = line;
          continue;
        }
        name = line;
        ret[name] = {xy: new Point(0, 0), size: new Point(0, 0)};
      } else if (name != null) {
        var key = line.substr(0, sep);
        if (key == 'xy' || key == 'size') {
          var val = line.substr(sep+1).split(',');
          var x = Std.parseInt(val[0]);
          var y = Std.parseInt(val[1]);
          if (key == 'xy') ret[name].xy = new Point(x, y);
          if (key == 'size') ret[name].size = new Point(x, y);
        }
      }
    }
    return ret;
  }

  function loadSpine(spine: String) {

  }

  override public function render(view: View) {
  }

  override function getImage(): Image {
    return null;
  }
}
