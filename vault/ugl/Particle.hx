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
  var _color: UInt;
  var _size: Value;
  var _speed: Value;
  var _angle: Value;
  var _count: Value;
  var _duration: Value;
  var _delay: Value;

  public function new() {
    super();
    pos.x = pos.y = 240;
    _color = 0xFFFFFF;
    _size = Const(1);
    _count = Const(100);
    _speed = Const(50);
    _angle = Rand(0, 2*Math.PI);
    _delay = Rand(0.1, 0.1);
    _duration = Rand(1.0, 0.2);
  }

  public function xy(x: Float, y: Float): Particle {
    pos.x = x;
    pos.y = y;
    return this;
  }
  public function color(c:UInt): Particle { _color = c; return this; }
  public function count(v: Value): Particle { _count = v; return this; }
  public function size(v: Value): Particle { _size = v; return this; }
  public function speed(v: Value): Particle { _speed = v; return this; }
  public function direction(v: Value): Particle { _angle = v; return this; }
  public function delay(v: Value): Particle { _delay = v; return this; }
  public function duration(v: Value): Particle { _duration = v; return this; }

  var particles : List<Part> = null;
  function create() {
    var c = Math.round(getValue(_count));
    particles = new List<Part>();
    for (i in 0...c) {
      var v = new Vec2(getValue(_speed), 0);
      v.rotate(getValue(_angle));
      var p: Part = {
        pos: pos.copy(),
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
