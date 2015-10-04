package vault;

import haxe.ds.ObjectMap;
import vault.Vec2;

/*
Grid is a 2D platform collision class

*/

typedef Rect = {
  var x: Float;
  var y: Float;
  var w: Float;
  var h: Float;
}

typedef Tile = {
  var block: Bool;
  var type: Int;
}

typedef Object = {
  var pos: Vec2;
  var rect: Rect;
  var touch: Int; // up, right, down, left.
  var collide: Int; // up, right, down, left.
}

class Grid {
  public var map: Array<Array<Tile>>;
  public var tilesize: Int;
  public var width: Int;
  public var height: Int;
  public var objects: ObjectMap<Dynamic, Object>;

  public function new(width: Int, height: Int, tilesize: Int) {
    this.width = width;
    this.height = height;
    this.tilesize = tilesize;
    map = [];
    for (x in 0...width) {
      var c = new Array<Tile>();
      for (y in 0...height) {
        c.push(null);
      }
      map.push(c);
    }
    objects = new ObjectMap<Dynamic, Object>();
  }

  public function load(obj: Array<Tile>, data: String) {
    var x = 0;
    var y = 0;
    for (i in 0...data.length) {
      var c = data.charAt(i);
      if (c == '\n' || c == ' ') continue;
      if (c != '.') {
        map[x][y] = obj[Std.parseInt(c)];
      }
      x++;
      if (x >= width) {
        x = 0;
        y++;
      }
    }
  }

  public function add(o: Dynamic, p: Vec2, bx: Float, by: Float, bw: Float, bh: Float) {
    objects.set(o, {pos: p.copy(), rect: {x:bx, y:by, w:bw, h:bh}, touch: 0, collide: 0 });
  }

  public function get(o: Dynamic): Object {
    return objects.get(o);
  }

  function hit(rect: Rect, pos: Vec2): Bool {
    var x1 = Std.int((pos.x + rect.x)/tilesize);
    var y1 = Std.int((pos.y + rect.y)/tilesize);
    var x2 = Std.int((pos.x + rect.x + rect.w)/tilesize)+1;
    var y2 = Std.int((pos.y + rect.y + rect.h)/tilesize)+1;
    for (xx in x1...x2) {
      for (yy in y1...y2) {
        if (map[xx][yy] != null && map[xx][yy].block) {
          return false;
        }
      }
    }
    return true;
  }

  function tryDelta(obj: Object, dx: Float, dy: Float): Bool {
    if (dx == 0 && dy == 0) return true;
    var pos = obj.pos.copy();
    pos.x += dx;
    pos.y += dy;
    if (hit(obj.rect, pos)) {
      obj.pos.x += dx;
      obj.pos.y += dy;
      return true;
    }
    if (dy < 0) obj.collide |= 1;
    if (dx > 0) obj.collide |= 2;
    if (dy > 0) obj.collide |= 4;
    if (dx < 0) obj.collide |= 8;

    if (dx > 0) {
      var p = obj.pos.x + obj.rect.x + obj.rect.w;
      var go = Std.int((p + dx)/tilesize)*tilesize - 1;
      tryDelta(obj, go - p, 0);
    } else if (dx < 0) {
      var p = obj.pos.x + obj.rect.x;
      var go = Math.ceil((p + dx)/tilesize)*tilesize;
      tryDelta(obj, go - p, 0);
    } else if (dy < 0) {
      var p = obj.pos.y + obj.rect.y;
      var go = Math.ceil((p + dy)/tilesize)*tilesize;
      tryDelta(obj, 0, go - p);
    } else if (dy > 0) {
      var p = obj.pos.y + obj.rect.y + obj.rect.h;
      var go = Std.int((p + dy)/tilesize)*tilesize - 1;
      tryDelta(obj, 0, go - p);
    }
    return false;
  }

  public function update(o: Dynamic, p: Vec2): Vec2 {
    var obj = objects.get(o);

    obj.collide = 0;

    var delta = p.distance(obj.pos);
    var steps = delta.length/tilesize;
    for (i in 0...Math.ceil(steps)) {
      delta.normalize(tilesize*Math.min(1, steps-i));
      var ret: Bool = true;
      if (delta.x >= delta.y) {
        ret = tryDelta(obj, delta.x, 0) && ret;
        ret = tryDelta(obj, 0, delta.y) && ret;
      } else {
        ret = tryDelta(obj, 0, delta.y) && ret;
        ret = tryDelta(obj, delta.x, 0) && ret;
      }
      if (!ret) {
        break;
      }
    }

    obj.touch = 0;

    var sp = 2;
    var left = Std.int((obj.pos.x + obj.rect.x-sp)/tilesize);
    var up = Std.int((obj.pos.y + obj.rect.y-sp)/tilesize);
    var right = Std.int((obj.pos.x + obj.rect.x + obj.rect.w+sp)/tilesize);
    var down = Std.int((obj.pos.y + obj.rect.y + obj.rect.h+sp)/tilesize);

    var x1 = Std.int((obj.pos.x + obj.rect.x)/tilesize);
    var y1 = Std.int((obj.pos.y + obj.rect.y)/tilesize);
    var x2 = Std.int((obj.pos.x + obj.rect.x + obj.rect.w)/tilesize);
    var y2 = Std.int((obj.pos.y + obj.rect.y + obj.rect.h)/tilesize);

    for (xx in x1...x2+1) {
      if (map[xx][up] != null && map[xx][up].block) obj.touch |= 1;
      if (map[xx][down] != null && map[xx][down].block) obj.touch |= 4;
    }
    for (yy in y1...y2+1) {
      if (map[right][yy] != null && map[right][yy].block) obj.touch |= 2;
      if (map[left][yy] != null && map[left][yy].block) obj.touch |= 8;
    }

    return obj.pos.copy();
  }

}
