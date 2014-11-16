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

class SpineRegionAttachment extends RegionAttachment {
  public var image: Image = null;
}

class SpineAttachmentLoader implements AttachmentLoader {
  var atlas: Map<String, Image>;
  public function new(atlas: Map<String, Image>) {
    this.atlas = atlas;
  }

  public function newAttachment (skin:Skin, type:AttachmentType, name:String):Attachment {
    if (type != region) {
      throw "don't know how to deal with attachment type: " + type;
    }

    var att = new SpineRegionAttachment(name);
    att.image = atlas[name];

    return att;
  }
}

class Spine extends Sprite {
  var atlas: Map<String, Image>;
  var skeletonData: SkeletonData;
  public var skeleton: Skeleton;
  public var state: AnimationState;

  public function new(basename: String, data: SkeletonData = null) {
    super();

    if (data == null) {
      atlas = loadAtlas(basename + ".atlas");
      var json = new SkeletonJson(new SpineAttachmentLoader(atlas));
      skeletonData = json.readSkeletonData(Assets.getText(basename + ".json"), basename);
    } else {
      skeletonData = data;
    }
    skeleton = new Skeleton(skeletonData);
    state = new AnimationState(new AnimationStateData(skeletonData));
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

      var x = bone.worldX*0.05 + 0.05*att.x * bone.m00 + 0.05*att.y * bone.m01;
      var y = (bone.worldY*0.05 + 0.05*att.x * bone.m10 + 0.05*att.y * bone.m11);

      var angle = bone.worldRotation + att.rotation;

      var scaleX = bone.worldScaleX + att.scaleX - 1;
      var scaleY = bone.worldScaleY + att.scaleY - 1;

      if (bone.worldFlipX) {
        scaleX = -scaleX;
        angle = -angle;
      }
      if (bone.worldFlipY) {
        scaleY = -scaleY;
        angle = -angle;
      }

      view.draw(att.image, pos.x + x, pos.y - y, angle*Math.PI/180, scaleX, scaleY, 1.0);
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
            // im.offset.x = im.offset.y = 0;
            ret[name] = im;
          }
        }
      }
    }
    return ret;
  }
}
