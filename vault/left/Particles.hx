package vault.left;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import haxe.crypto.Base64;
import haxe.io.BytesInput;
import haxe.io.Path;
import openfl.Assets;
import vault.Graphics;
import vault.left.Left;
import vault.left.View;
import vault.TiffDecoder;
import vault.Vec2;

typedef Particle = {
  var start: Vec2;
  var pos: Vec2;
  var direction: Vec2;
  var rotation: Float;
  var radius: Float;
  var angle: Float;
  var size: Float;
  var ttl: Float;
  var r: Float;
  var g: Float;
  var b: Float;
  var a: Float;

  var rDelta: Float;
  var gDelta: Float;
  var bDelta: Float;
  var aDelta: Float;
  var rotationDelta: Float;
  var radiusDelta: Float;
  var angleDelta: Float;
  var sizeDelta: Float;
  var radialAcc: Float;
  var tangentialAcc: Float;
};

enum EmitterType {
  GRAVITY;
  RADIAL;
}
enum PositionType {
  FREE;
  RELATIVE;
  GROUPED;
}
enum BlendFunc {
  BF_ZERO;
  BF_ONE;
  BF_DST_COLOR;
  BF_ONE_MINUS_DST_COLOR;
  BF_SRC_ALPHA;
  BF_ONE_MINUS_SRC_ALPHA;
  BF_DST_ALPHA;
  BF_ONE_MINUS_DST_ALPHA;
  BF_SRC_ALPHA_SATURATE;
}
enum Value {
  VALUE(base: Float, variance: Float);
}

class Particles extends View {
  public var emitterType: EmitterType;
  public var maxParticles: Int;
  public var positionType: PositionType;
  public var duration: Float;
  public var gravity: Vec2;
  public var particleLifespan: Value;
  public var speed: Value;
  public var positionVariance: Vec2;
  public var angle: Value;
  public var startParticleSize: Value;
  public var finishParticleSize: Value;
  public var startColorR: Value;
  public var startColorG: Value;
  public var startColorB: Value;
  public var startColorA: Value;
  public var finishColorR: Value;
  public var finishColorG: Value;
  public var finishColorB: Value;
  public var finishColorA: Value;
  public var minRadius: Value;
  public var maxRadius: Value;
  public var rotationStart: Value;
  public var rotationEnd: Value;
  public var rotatePerSecond: Value;
  public var radialAcceleration: Value;
  public var tangentialAcceleration: Value;
  public var blendFuncSource: BlendFunc;
  public var blendFuncDestination: BlendFunc;
  public var textureBitmapData: BitmapData;
  public var yCoordMultipler: Float;

  var image: Image;

  public var active: Bool;
  public var restart: Bool;
  public var emitCounter: Float;
  public var elapsedTime: Float;

  public var pos: Vec2;

  var particles: Array<Particle>;
  var particleCount: Int;

  public function new(filename: String = null) {
    super();

    // TODO: add reasonable default values.

    if (filename != null) {
      var map = haxe.Json.parse(Assets.getText(filename));

      emitterType = switch(map.emitterType) {
        case 0: GRAVITY;
        case 1: RADIAL;
        default: GRAVITY;
      };
      maxParticles = map.maxParticles;
      // TODO: positionType
      positionType = FREE;
      duration = map.duration;
      gravity = new Vec2(map.gravityx, map.gravityy);
      particleLifespan = VALUE(map.particleLifespan, map.particleLifespanVariance);
      speed = VALUE(map.speed, map.speedVariance);
      positionVariance = new Vec2(map.sourcePositionVariancex, map.sourcePositionVariancey);
      angle = VALUE(map.angle*Math.PI/180, map.angleVariance*Math.PI/180);
      startParticleSize = VALUE(map.startParticleSize, map.startParticleSizeVariance);
      finishParticleSize = VALUE(map.finishParticleSize, map.finishParticleSizeVariance);
      startColorR = VALUE(map.startColorRed, map.startColorVarianceRed);
      startColorG = VALUE(map.startColorGreen, map.startColorVarianceGreen);
      startColorB = VALUE(map.startColorBlue, map.startColorVarianceBlue);
      startColorA = VALUE(map.startColorAlpha, map.startColorVarianceAlpha);
      finishColorR = VALUE(map.finishColorRed, map.finishColorVarianceRed);
      finishColorG = VALUE(map.finishColorGreen, map.finishColorVarianceGreen);
      finishColorB = VALUE(map.finishColorBlue, map.finishColorVarianceBlue);
      finishColorA = VALUE(map.finishColorAlpha, map.finishColorVarianceAlpha);
      minRadius = VALUE(map.minRadius, map.minRadiusVariance);
      maxRadius = VALUE(map.maxRadius, map.maxRadiusVariance);
      rotationStart = VALUE(map.rotationStart*Math.PI/180, map.rotationStartVariance*Math.PI/180);
      rotationEnd = VALUE(map.rotationEnd*Math.PI/180, map.rotationEndVariance*Math.PI/180);
      rotatePerSecond = VALUE(map.rotatePerSecond*Math.PI/180, map.rotatePerSecondVariance*Math.PI/180);
      radialAcceleration = VALUE(map.radialAcceleration, map.radialAccelerationVariance);
      tangentialAcceleration = VALUE(map.tangentialAcceleration, map.tangentialAccelerationVariance);
      yCoordMultipler = map.yCoordFlipped == 1 ? -1.0 : 1.0;
      // TODO: blendFuncSource / blendFuncDestination
      blendFuncSource = switch(map.blendFuncSource) {
        case 1: BF_ONE;
        case 772: BF_DST_ALPHA;
        default: BF_SRC_ALPHA;
      };

      blendFuncDestination = switch(map.blendFuncDestination) {
        case 1: BF_ONE;
        case 772: BF_DST_ALPHA;
        default: BF_DST_ALPHA;
      };

      if (Type.enumEq(blendFuncSource, BF_DST_ALPHA)) {
        blendFuncSource = BF_ONE;
      }

      if (Type.enumEq(blendFuncDestination, BF_DST_ALPHA)) {
        blendFuncDestination = BF_ONE;
      }

      if (map.textureImageData != "") {
        var data = Base64.decode(map.textureImageData);
        if (data.get(0) == 0x1f && data.get(1) == 0x8b) {
          var reader = new format.gz.Reader(new BytesInput(data));
          data = reader.read().data;
        }
        var decoded = TiffDecoder.decode(data);
        textureBitmapData = new BitmapData(decoded.width, decoded.height, true, 0);
        textureBitmapData.setPixels(new Rectangle(0, 0, decoded.width, decoded.height), decoded.pixels);
      } else {
        textureBitmapData = Assets.getBitmapData(Path.directory(filename) + "/" + map.textureFileName);
      }

      image = createImage(textureBitmapData);
    }

    active = true;
    restart = true;
    pos = new Vec2(0, 0);

    reset();
  }

  function reset() {
    particles = [];
    for (i in 0...maxParticles) {
      particles.push({
        start: new Vec2(0, 0),
        pos: new Vec2(0, 0),
        direction: new Vec2(0, 0),
        r: 1.0,
        g: 1.0,
        b: 1.0,
        a: 1.0,
        rotation: 0.0,
        radius: 0.0,
        angle: 0.0,
        size: 0.0,
        ttl: 0.0,
        rDelta: 1.0,
        gDelta: 1.0,
        bDelta: 1.0,
        aDelta: 1.0,
        rotationDelta: 0.0,
        radiusDelta: 0.0,
        angleDelta: 0.0,
        sizeDelta: 0.0,
        radialAcc: 0.0,
        tangentialAcc: 0.0
      });
    }
    particleCount = 0;
    emitCounter = 0.0;
    elapsedTime = 0.0;
    flags = openfl.display.Tilesheet.TILE_BLEND_NORMAL;
    if (Type.enumEq(blendFuncSource, BF_SRC_ALPHA) &&
        Type.enumEq(blendFuncDestination, BF_ONE)) {
      flags = openfl.display.Tilesheet.TILE_BLEND_ADD;
    }
  }

  public function start(pos: Vec2 = null) {
    if (pos != null) {
      this.pos.x = pos.x;
      this.pos.y = pos.y;
    }
    active = true;
  }

  public function stop() {
    active = false;
    elapsedTime = 0.0;
    emitCounter = 0.0;
  }

  public function update() {
    if (active && maxParticles > 0) {
      var rate = (switch(particleLifespan) { case VALUE(a, b): a; }) / maxParticles;
      emitCounter += Left.elapsed;
      while (particleCount < maxParticles && emitCounter >= rate) {
        particleInit(particles[particleCount++]);
        emitCounter -= rate;
      }
      elapsedTime += Left.elapsed;
      if (duration >= 0.0 && duration < elapsedTime) {
        stop();
      }
    }

    var i = 0;
    while (i < particleCount) {
      particleUpdate(particles[i]);
      if (particles[i].ttl > 0.0) {
        i++;
      } else {
        if (i != particleCount - 1) {
          var tmp = particles[i];
          particles[i] = particles[particleCount - 1];
          particles[particleCount - 1] = tmp;
        }
        particleCount -= 1;
      }
    }

    if (particleCount <= 0 && restart) {
      active = true;
    }

    for (i in 0...particleCount) {
      var p = particles[i];
      draw(image, p.pos.x, p.pos.y, p.rotation, p.size/image.width, p.size/image.width,
        p.a, p.r, p.g, p.b);
    }
    render();
  }

  function particleInit(p: Particle) {
    p.ttl = Math.max(0.0001, value(particleLifespan));
    p.start.x = pos.x;
    p.start.y = pos.y;

    p.size = Math.max(0.0, value(startParticleSize));
    p.sizeDelta = (Math.max(0.0, value(finishParticleSize)) - p.size) / p.ttl;
    p.rotation = value(rotationStart);
    p.rotationDelta = (value(rotationEnd) - p.rotation) / p.ttl;
    p.angle = value(angle);
    p.angleDelta = value(rotatePerSecond) / p.ttl;
    p.radius = value(maxRadius);
    p.radiusDelta = (value(minRadius) - p.radius) / p.ttl;

    var ds = value(speed);
    p.pos.x = p.start.x + positionVariance.x * (Math.random()*2.0 - 1.0);
    p.pos.y = p.start.y + positionVariance.y * (Math.random()*2.0 - 1.0);
    p.direction.x = Math.cos(p.angle) * ds;
    p.direction.y = Math.sin(p.angle) * ds;
    p.radialAcc = value(radialAcceleration);
    p.tangentialAcc = value(tangentialAcceleration);

    p.r = EMath.clamp(value(startColorR), 0.0, 1.0);
    p.g = EMath.clamp(value(startColorG), 0.0, 1.0);
    p.b = EMath.clamp(value(startColorB), 0.0, 1.0);
    p.a = EMath.clamp(value(startColorA), 0.0, 1.0);

    p.rDelta = (EMath.clamp(value(finishColorR), 0.0, 1.0) - p.r) / p.ttl;
    p.gDelta = (EMath.clamp(value(finishColorG), 0.0, 1.0) - p.g) / p.ttl;
    p.bDelta = (EMath.clamp(value(finishColorB), 0.0, 1.0) - p.b) / p.ttl;
    p.aDelta = (EMath.clamp(value(finishColorA), 0.0, 1.0) - p.a) / p.ttl;
  }

  function particleUpdate(p: Particle) {
    p.ttl -= Left.elapsed;

    if (Type.enumEq(emitterType, RADIAL)) {
      p.angle += p.angleDelta * Left.elapsed;
      p.radius += p.radiusDelta * Left.elapsed;
      p.pos.x = p.start.x - Math.cos(p.angle) * p.radius;
      p.pos.y = p.start.y - Math.sin(p.angle) * p.radius * yCoordMultipler;
    } else {
      p.pos.x -= p.start.x;
      p.pos.y = (p.pos.y - p.start.y)*yCoordMultipler;
      var radial = p.pos.copy();
      radial.normalize();
      var tang = new Vec2(-radial.y, radial.x);
      radial.mul(p.radialAcc);
      tang.mul(p.tangentialAcc);
      radial.add(tang);
      radial.add(gravity);
      radial.mul(Left.elapsed);
      p.direction.add(radial);
      p.pos.x += p.start.x + p.direction.x*Left.elapsed;
      p.pos.y = (p.pos.y + p.direction.y * Left.elapsed) * yCoordMultipler + p.start.y;
    }

    // update color.
    p.r += p.rDelta * Left.elapsed;
    p.g += p.gDelta * Left.elapsed;
    p.b += p.bDelta * Left.elapsed;
    p.a += p.aDelta * Left.elapsed;

    p.size = Math.max(0, p.size + p.sizeDelta * Left.elapsed);
    p.rotation += p.rotationDelta * Left.elapsed;
  }

  function value(v: Value): Float {
    return switch(v) {
      case VALUE(a, b): a + b*(Math.random()*2.0 - 1.0);
    }
  }
}
