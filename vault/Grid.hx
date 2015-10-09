package vault;

import flash.display.Sprite;
import haxe.ds.ObjectMap;
import vault.Vec2;

/*
Grid is a 2D platform collision class

TODO:
- support for raycasting-view

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
  public var offset: Vec2;
  public var map: Array<Array<Tile>>;
  public var tilesize: Int;
  public var width: Int;
  public var height: Int;
  public var objects: ObjectMap<Dynamic, Object>;
  var debugsprite: Sprite;

  public function new(width: Int, height: Int, tilesize: Int, debugsprite: Sprite) {
    this.width = width;
    this.height = height;
    this.tilesize = tilesize;
    this.debugsprite = debugsprite;
    offset = new Vec2(0, 0);
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
        var o = obj[Std.parseInt(c)];
        map[x][y] = { block: o.block, type: o.type };
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
    var x1 = Std.int((pos.x + rect.x - offset.x)/tilesize);
    var y1 = Std.int((pos.y + rect.y - offset.y)/tilesize);
    var x2 = Std.int((pos.x + rect.x + rect.w - 1 - offset.x)/tilesize);
    var y2 = Std.int((pos.y + rect.y + rect.h - 1 - offset.y)/tilesize);

    if (x1 < 0 || y1 < 0 || x2 >= map.length || y2 >= map[0].length) {
      return false;
    }

    for (xx in x1...x2+1) {
      for (yy in y1...y2+1) {
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
      var p = obj.pos.x + obj.rect.x + obj.rect.w - offset.x;
      var go = Math.floor((p + dx)/tilesize)*tilesize;
      tryDelta(obj, go - p, 0);
    } else if (dx < 0) {
      var p = obj.pos.x + obj.rect.x - offset.x;
      var go = Math.ceil((p + dx)/tilesize)*tilesize;
      tryDelta(obj, go - p, 0);
    } else if (dy < 0) {
      var p = obj.pos.y + obj.rect.y - offset.y;
      var go = Math.ceil((p + dy)/tilesize)*tilesize;
      tryDelta(obj, 0, go - p);
    } else if (dy > 0) {
      var p = obj.pos.y + obj.rect.y + obj.rect.h - offset.y;
      var go = Math.floor((p + dy)/tilesize)*tilesize;
      tryDelta(obj, 0, go - p);
    }
    return false;
  }

  public function updateOffset(delta: Vec2) {
    var d = delta.distance(offset);
    offset = delta.copy();
    for (k in objects) {
      k.pos.add(d);
    }
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

    var sp = 1;
    var left = Std.int((obj.pos.x + obj.rect.x-sp - offset.x)/tilesize);
    var up = Std.int((obj.pos.y + obj.rect.y-sp - offset.y)/tilesize);
    var right = Std.int((obj.pos.x + obj.rect.x + obj.rect.w+sp - offset.x)/tilesize);
    var down = Std.int((obj.pos.y + obj.rect.y + obj.rect.h+sp - offset.y)/tilesize);

    var x1 = Std.int((obj.pos.x + obj.rect.x - offset.x)/tilesize);
    var y1 = Std.int((obj.pos.y + obj.rect.y - offset.y)/tilesize);
    var x2 = Std.int((obj.pos.x + obj.rect.x + obj.rect.w - 1 - offset.x)/tilesize);
    var y2 = Std.int((obj.pos.y + obj.rect.y + obj.rect.h - 1 - offset.y)/tilesize);

    for (xx in x1...x2+1) {
      if (up < 0 || up >= map[0].length || xx < 0 || xx >= map.length ||
          (map[xx][up] != null && map[xx][up].block)) obj.touch |= 1;
      if (down < 0 || down >= map[0].length || xx < 0 || xx >= map.length ||
          (map[xx][down] != null && map[xx][down].block)) obj.touch |= 4;
    }
    for (yy in y1...y2+1) {
      if (right < 0 || right >= map.length || yy < 0 || yy >= map[0].length ||
          (map[right][yy] != null && map[right][yy].block)) obj.touch |= 2;
      if (left < 0 || left >= map.length || yy < 0 || yy >= map[0].length ||
          (map[left][yy] != null && map[left][yy].block)) obj.touch |= 8;
    }

    return obj.pos.copy();
  }

  public function debug() {
    return;
    var gfx = debugsprite.graphics;
    gfx.clear();
    for (k in objects) {
      gfx.lineStyle(1, 0xFF0000, 0.2);
      gfx.drawRect(k.pos.x + k.rect.x, k.pos.y + k.rect.y, k.rect.w, k.rect.h);
    }
  }
}
