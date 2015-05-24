package vault;

import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.GraphicsPathWinding;
import flash.display.IGraphicsData;
import flash.display.InterpolationMethod;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.display.TriangleCulling;
import flash.geom.Matrix;
import flash.Vector;
import openfl.display.Tilesheet;

class Graphics {
  var gfx: flash.display.Graphics;
  public function new(sprite: Sprite) {
    gfx = sprite.graphics;
  }

  public function donut(x: Float, y: Float, r0: Float, r1: Float, b: Float, e: Float) {
    this.arc(x, y, r0, b, e, true);
    this.arc(x, y, r1, e, b, false);
  }

  public function arc(x:Float, y:Float, r:Float, b:Float, e:Float, ?jump:Bool = false) {
    var segments = Math.ceil(Math.abs(e-b)/(Math.PI/4));
    var theta = -(e-b)/segments;
    var angle = -b;
    var ctrlRadius = r/Math.cos(theta/2);
    if (jump) {
      gfx.moveTo(x+Math.cos(angle)*r, y+Math.sin(angle)*r);
    } else {
      gfx.lineTo(x+Math.cos(angle)*r, y+Math.sin(angle)*r);
    }
    for (i in 0...segments) {
      angle += theta;
      var angleMid = angle-(theta/2);
      var cx = x+Math.cos(angleMid)*(ctrlRadius);
      var cy = y+Math.sin(angleMid)*(ctrlRadius);
      // calculate our end point
      var px = x+Math.cos(angle)*r;
      var py = y+Math.sin(angle)*r;
      // draw the circle segment
      gfx.curveTo(cx, cy, px, py);
    }
    return this;
  }

  public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false) {
    gfx.beginBitmapFill(bitmap, matrix, repeat, smooth);
  }
  public function beginFill(color:Int = 0, alpha:Float = 1) {
    gfx.beginFill(color, alpha);
  }
  public function beginGradientFill(type:GradientType, colors:Array<Dynamic>, alphas:Array<Dynamic>, ratios:Array<Dynamic>, matrix:Matrix = null, spreadMethod:Null<SpreadMethod> = null, interpolationMethod:Null<InterpolationMethod> = null, focalPointRatio:Null<Float> = null) {
    gfx.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
  }
  public function clear() {
    gfx.clear();
  }
  public function copyFrom(sourceGraphics:flash.display.Graphics) {
    gfx.copyFrom(sourceGraphics);
  }
  public function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float) {
    gfx.cubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
  }
  public function curveTo (controlX:Float, controlY:Float, anchorX:Float, anchorY:Float) {
    gfx.curveTo(controlX, controlY, anchorX, anchorY);
  }
  public function drawCircle (x:Float, y:Float, radius:Float) {
    gfx.drawCircle(x, y, radius);
  }
  public function drawEllipse (x:Float, y:Float, width:Float, height:Float) {
    gfx.drawEllipse(x, y, width, height);
  }
  public function drawGraphicsData (graphicsData:Vector<IGraphicsData>) {
    gfx.drawGraphicsData(graphicsData);
  }
  public function drawPath (commands:Vector<Int>, data:Vector<Float>, winding:GraphicsPathWinding = null) {
    gfx.drawPath(commands, data, winding);
  }
  public function drawRect (x:Float, y:Float, width:Float, height:Float) {
    gfx.drawRect(x, y, width, height);
  }
  public function drawRoundRect (x:Float, y:Float, width:Float, height:Float, rx:Float, ry:Float = -1) {
    gfx.drawRoundRect(x, y, width, height, rx, ry);
  }
  public function drawRoundRectComplex (x:Float, y:Float, width:Float, height:Float, topLeftRadius:Float, topRightRadius:Float, bottomLeftRadius:Float, bottomRightRadius:Float) {
    gfx.drawRoundRectComplex(x, y, width, height, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius);
  }
  public function drawTiles (sheet:Tilesheet, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, count:Int = -1) {
    gfx.drawTiles(sheet, tileData, smooth, flags, count);
  }
  public function drawTriangles (vertices:Vector<Float>, ?indices:Vector<Int> = null, ?uvtData:Vector<Float> = null, ?culling:TriangleCulling = null, ?colors:Vector<Int>, blendMode:Int = 0) {
    gfx.drawTriangles(vertices, indices, uvtData, culling, colors, blendMode);
  }
  public function endFill () {
    gfx.endFill();
  }
  public function lineBitmapStyle (bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false) {
    gfx.lineBitmapStyle(bitmap, matrix, repeat, smooth);
  }
  public function lineGradientStyle (type:GradientType, colors:Array<Dynamic>, alphas:Array<Dynamic>, ratios:Array<Dynamic>, matrix:Matrix = null, spreadMethod:SpreadMethod = null, interpolationMethod:InterpolationMethod = null, focalPointRatio:Null<Float> = null) {
    gfx.lineGradientStyle(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
  }
  public function lineStyle (thickness:Null<Float> = null, color:Null<Int> = null, alpha:Null<Float> = null, pixelHinting:Null<Bool> = null, scaleMode:LineScaleMode = null, caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Null<Float> = null) {
    gfx.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
  }
  public function lineTo (x:Float, y:Float) {
    gfx.lineTo(x, y);
  }
  public function moveTo (x:Float, y:Float) {
    gfx.moveTo(x, y);
  }
}
