package vault.left;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import haxe.io.Path;
import haxe.Json;
import openfl.Assets;
import spinehaxe.animation.AnimationState;
import spinehaxe.animation.AnimationStateData;
import spinehaxe.attachments.Attachment;
import spinehaxe.attachments.AttachmentLoader;
import spinehaxe.attachments.AttachmentType;
import spinehaxe.attachments.RegionAttachment;
import spinehaxe.Bone;
import spinehaxe.Skeleton;
import spinehaxe.SkeletonData;
import spinehaxe.SkeletonJson;
import spinehaxe.Skin;
import vault.Point;
import vault.Vec2;

class Spine extends Sprite {
  var skels: Map<String, SkeletonData>;
  var currentSkel: String = null;
  var anims: Map<String, String>;
  public var skeleton: Skeleton;
  public var state: AnimationState;
  public var offset: Vec2;

  public function new(names: Map<String, String>, parent: Spine = null) {
    super();

    if (parent == null) {
      skels = new Map();
      anims = new Map();
      for (k in names.keys()) {
        var basename = names[k];
        var atlas = loadAtlas(basename + ".atlas");
        var json = new SkeletonJson(new SpineAttachmentLoader(atlas));
        skels[k] = json.readSkeletonData(Assets.getText(basename + ".json"), basename);
        for (a in skels[k].animations) {
          anims[a.name] = k;
        }
      }
    } else {
      skels = parent.skels;
      anims = parent.anims;
    }
    var first: String = null;
    for (k in names.keys()) {
      first = k;
      break;
    }
    setSkel(first);
    offset = new Vec2(0, 0);
  }

  public function setAnimation(name: String, loop: Bool = false) {
    setSkel(anims[name]);
    skeleton.setToSetupPose();
    state.setAnimationByName(0, name, loop);
    state.update(0);
    state.apply(skeleton);
    skeleton.updateWorldTransform();
    skeleton.update(0);
  }

  public function setSkel(name: String) {
    if (currentSkel == name) return;
    skeleton = new Skeleton(skels[name]);
    state = new AnimationState(new AnimationStateData(skels[name]));
    currentSkel = name;
  }

  override public function update() {
    state.update(Left.elapsed);
    state.apply(skeleton);
    skeleton.updateWorldTransform();
    skeleton.update(Left.elapsed);
  }

  override public function render(view: View) {
    for (slot in skeleton.drawOrder) {
      var att:SpineRegionAttachment = cast slot.attachment;
      var bone:Bone = slot.bone;

      var x = bone.worldX + att.x * bone.m00 + att.y * bone.m01;
      var y = bone.worldY + att.x * bone.m10 + att.y * bone.m11;
      var angle = bone.worldRotation + att.rotation;
      var bonescaleX = bone.worldScaleY + att.scaleX - 1;
      var bonescaleY = bone.worldScaleX + att.scaleY - 1;

      if (bone.worldFlipX) {
        bonescaleX = -bonescaleX;
        angle = -angle;
      }
      if (bone.worldFlipY) {
        bonescaleY = -bonescaleY;
        angle = -angle;
      }

      view.draw(att.image, pos.x + (offset.x + x)*this.scaleX, pos.y - (y - offset.y)*this.scaleY, angle*Math.PI/180, bonescaleX*this.scaleX, bonescaleY*this.scaleY, 1.0);
    }

    // view.postDraw = drawSkel;
  }

  public function drawSkel(gfx: flash.display.Graphics) {
    for (bone in skeleton.bones) {
      gfx.lineStyle(2, 0xFF00FF);
      gfx.moveTo(pos.x + bone.worldX*this.scaleX, pos.y - bone.worldY*this.scaleY);
      var v = new Vec2(0, bone.data.length);
      v.angle = bone.worldRotation*Math.PI/180;
      v.x *= bone.worldFlipX ? -bone.worldScaleX : bone.worldScaleX;
      v.y *= bone.worldFlipY ? -bone.worldScaleY : bone.worldScaleY;
      v.x += bone.worldX;
      v.y += bone.worldY;
      gfx.lineTo(pos.x + v.x*this.scaleX, pos.y - v.y*this.scaleY);
    }
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
            var im = Image.create(b);
            ret[name] = im;
          }
        }
      }
    }
    return ret;
  }
}

class SpineRegionAttachment extends RegionAttachment {
  public var image: Image = null;
}

class SpineAttachmentLoader implements AttachmentLoader {
  var atlas: Map<String, Image>;
  public function new(atlas: Map<String, Image>) {
    this.atlas = atlas;
  }

  /** @return May be null to not load an attachment. */
  public function newRegionAttachment (skin:Skin, name:String, path:String) : RegionAttachment {
    var att = new SpineRegionAttachment(name);
    att.image = atlas[name];
    return att;
  }

  /** @return May be null to not load an attachment. */
  public function newMeshAttachment (skin:Skin, name:String, path:String) : spinehaxe.attachments.MeshAttachment {
    return null;
  }

  /** @return May be null to not load an attachment. */
  public function newSkinnedMeshAttachment (skin:Skin, name:String, path:String) : spinehaxe.attachments.SkinnedMeshAttachment {
    return null;
  }

  /** @return May be null to not load an attachment. */
  public function newBoundingBoxAttachment (skin:Skin, name:String) : spinehaxe.attachments.BoundingBoxAttachment {
    return null;
  }
}

