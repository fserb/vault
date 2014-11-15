package vault.left;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import haxe.io.Path;
import haxe.Json;
import openfl.Assets;
import vault.Point;
import vault.Vec2;

typedef Bone = {
  var name: String;
  var length: Float;
  var parent: Bone;
  var pos: Vec2;
  var angle: Float;
  var scale: Vec2;
};

class Spine extends Sprite {
  var atlas: Map<String, Image>;
  var bones: Array<Bone>;
  var setup_bones: Array<Bone>;
  var slots: Array<{name: String, bone: Bone, attachment: String}>;
  var setup_slots: Array<{name: String, bone: Bone, attachment: String}>;
  var skins: Map<String, Map<String, Map<String, {x: Float, y: Float, angle: Float, width: Int, height: Int}>>>;
  var animations: Map<String, {
    bones: Map<String, {
      translate: Array<{time: Float, curve: Array<Float>, pos: Vec2}>,
      scale: Array<{time: Float, curve: Array<Float>, scale: Vec2}>,
      rotate: Array<{time: Float, curve: Array<Float>, angle: Float}>
      }>,
    events: Array<{time: Float, name: String, int: Int, float: Float, string: String}>,
    draworder: Array<{time: Float, offsets: Array<{slot: String, offset: Int}>}>
    }>;

  public function new(basename: String) {
    super();
    atlas = loadAtlas(basename + ".atlas");
    loadSpine(basename + ".json");
  }

  function loadSpine(filename: String) {
    var spine = Json.parse(Assets.getText(filename));
    bones = [];
    setup_bones = [];
    slots = [];
    setup_slots = [];
    skins = new Map();
    animations = new Map();

    var array: Array<Dynamic> = Reflect.field(spine, "bones");
    var get = function(d: Dynamic, f: String, v: Dynamic): Dynamic {
      if (!Reflect.hasField(d, f)) return v;
      return Reflect.field(d, f);
    }
    for (bd in array) {
      var b: Bone = { name: Reflect.field(bd, "name"),
                      pos: new Vec2(Reflect.field(bd, "x"), Reflect.field(bd, "y")),
                      length: get(bd, "length", 0.0),
                      parent: null,
                      angle: get(bd, "rotation", 0.0)*Math.PI/180,
                      scale: new Vec2(1.0, 1.0) };
      var parent = get(bd, "parent", null);
      if (parent != null) {
        b.parent = setup_bones.filter(function (x: Bone) return x.name == parent)[0];
      }
      setup_bones.push(b);
      bones.push(Reflect.copy(b));
    }

    array = Reflect.field(spine, "slots");
    for (sd in array) {
      var b = Reflect.field(sd, "bone");
      var sl = {name: Reflect.field(sd, "name"),
                bone: setup_bones.filter(function (x: Bone) return x.name == b)[0],
                attachment: Reflect.field(sd, "attachment")}
      setup_slots.push(sl);
      slots.push(Reflect.copy(sl));
    }

    var sks = Reflect.field(spine, "skins");
    for (name in Reflect.fields(sks)) {
      skins[name] = new Map();
      for (slotname in Reflect.fields(Reflect.field(sks, name))) {
        skins[name][slotname] = new Map();
        for (attname in Reflect.fields(Reflect.field(Reflect.field(sks, name), slotname))) {
          var f = Reflect.field(Reflect.field(Reflect.field(sks, name), slotname), attname);
          skins[name][slotname][attname] = { x: Reflect.field(f, "x"),
                                             y: Reflect.field(f, "y"),
                                             angle: Reflect.field(f, "rotation")*Math.PI/180,
                                             width: Reflect.field(f, "width"),
                                             height: Reflect.field(f, "height") };
        }
      }
    }
    trace(skins);

  }

  override public function render(view: View) {
  }

  override function getImage(): Image {
    return null;
  }

  function loadAtlas(filename: String): Map<String, Image> {
    var ret = new Map<String, Image>();
    var bmp = null;
    var name = null;
    var xy: Point = null;
    var size: Point = null;

    for (line in Assets.getText(filename).split("\n")) {
      line = StringTools.trim(line);
      if (line.length == 0) continue;
      var sep = line.indexOf(':');

      if (sep == -1) {
        if (bmp == null) {
          bmp = Assets.getBitmapData(Path.directory(filename) + "/" + line);
          continue;
        }
        name = line;
        xy = size = null;
      } else if (name != null) {
        var key = line.substr(0, sep);
        if (key == 'xy' || key == 'size') {
          var val = line.substr(sep+1).split(',');
          var x = Std.parseInt(val[0]);
          var y = Std.parseInt(val[1]);
          if (key == 'xy') xy = new Point(x, y);
          if (key == 'size') size = new Point(x, y);
          if (xy != null && size != null) {
            var b = new BitmapData(size.x, size.y, true, 0);
            b.copyPixels(bmp, new Rectangle(xy.x, xy.y, size.x, size.y), new flash.geom.Point(0, 0));
            ret[name] = Image.create(b);
          }
        }
      }
    }
    return ret;
  }
}
