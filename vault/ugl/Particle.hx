package vault.ugl;

import vault.Vec2;

enum Value {
  Const(v:Float);
  Rand(m:Float, d:Float);
}

typedef Part = {
  var pos: Vec2;
  var vel: Vec2;
  var size: Float;
  var delay: Float;
  var time: Float;
}

class Particle extends Entity {
  static var layer = 10;
  var _color: UInt;
  var _size: Value;
  var _speed: Value;
  var _angle: Value;
  var _count: Value;
  var _duration: Value;
  var _delay: Value;
  var _spread: Value;

  public function new() {
    super();
    pos.x = Game.width/2;
    pos.y = Game.height/2;
    _color = 0xFFFFFF;
    _size = Const(1);
    _count = Const(100);
    _speed = Const(50);
    _angle = Rand(0, 2*Math.PI);
    _delay = Const(0);
    _spread = Const(0);
    _duration = Rand(1.0, 0.2);
  }

  public function xy(x: Float, y: Float): Particle {
    pos.x = x;
    pos.y = y;
    return this;
  }
  public function color(c:UInt): Particle { _color = c; return this; }
  public function count(v: Float, ?r: Float = 0.0): Particle { _count = (r == 0) ? Const(v) : Rand(v, r); return this; }
  public function size(v: Float, ?r: Float = 0.0): Particle { _size = (r == 0) ? Const(v) : Rand(v, r); return this; }
  public function speed(v: Float, ?r: Float = 0.0): Particle { _speed = (r == 0) ? Const(v) : Rand(v, r); return this; }
  public function direction(v: Float, ?r: Float = 0.0): Particle { _angle = (r == 0) ? Const(v) : Rand(v, r); return this; }
  public function delay(v: Float, ?r: Float = 0.0): Particle { _delay = (r == 0) ? Const(v) : Rand(v, r); return this; }
  public function duration(v: Float, ?r: Float = 0.0): Particle { _duration = (r == 0) ? Const(v) : Rand(v, r); return this; }
  public function spread(v: Float, ?r: Float = 0.0): Particle { _spread = (r == 0) ? Const(v) : Rand(v, r); return this; }

  var particles : List<Part> = null;
  function create() {
    var c = Math.round(getValue(_count));
    particles = new List<Part>();
    for (i in 0...c) {
      var v = new Vec2(getValue(_speed), 0);
      v.angle = getValue(_angle);
      var po = pos.copy();
      var va = v.copy();
      va.normalize();
      va.mul(getValue(_spread));
      po.add(va);
      var p: Part = {
        pos: po,
        vel: v,
        size: getValue(_size),
        delay: getValue(_delay),
        time: getValue(_duration) };
      particles.add(p);
    }
    ticks = 0;
  }

  function getValue(v: Value): Float {
    return switch(v) {
      case Const(x): x;
      case Rand(m, d): m + d*Math.random();
    };
  }

  override public function update() {
    if (particles == null) {
      create();
    }
    sprite.graphics.clear();

    for (p in particles) {
      if (ticks < p.delay) {
        continue;
      }
      var t = 1.0 - (ticks - p.delay)/p.time;
      if (t < 0) {
        particles.remove(p);
        continue;
      }

      p.pos.x += p.vel.x*Game.time*t;
      p.pos.y += p.vel.y*Game.time*t;
      sprite.graphics.beginFill(_color, t);
      sprite.graphics.drawRect(p.pos.x - p.size/2.0, p.pos.y - p.size/2.0, p.size, p.size);
    }
    if (particles.length == 0) {
      remove();
    }

    deltasprite.x = sprite.width/2.0 - pos.x;
    deltasprite.y = sprite.height/2.0 - pos.y;
  }
}
