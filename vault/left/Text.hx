package vault.left;

import flash.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

enum TextAlign {
  LEFT;
  CENTER;
  RIGHT;
}

enum TextVAlign {
  TOP;
  MIDDLE;
  BOTTOM;
}

class Text extends Sprite {
  var tfield: TextField;
  public var format: TextFormat;

  public var text(default, set): String;
  public var size(default, set): Float;
  public var font(default, set): String;
  public var bold(default, set): Bool;
  public var color(default, set): UInt;
  public var align(default, set): TextAlign = CENTER;
  public var valign(default, set): TextVAlign = MIDDLE;

  public var twidth(get, null): Float;
  public var theight(get, null): Float;

  function get_twidth(): Float {
    return tfield.textWidth;
  }

  function get_theight(): Float {
    return tfield.textHeight;
  }

  function set_text(text: String): String {
    this.text = tfield.text = text;
    redo();
    return text;
  }

  function set_size(size: Float): Float {
    this.size = format.size = Std.int(size);
    redo();
    return size;
  }

  function set_bold(bold: Bool): Bool {
    this.bold = format.bold = bold;
    redo();
    return bold;
  }

  function set_font(font: String): String {
    this.font = format.font = font;
    redo();
    return font;
  }

  function set_color(color: UInt): UInt {
    this.color = format.color = color;
    redo();
    return color;
  }

  function set_align(align: TextAlign): TextAlign {
    this.align = align;
    redo();
    return align;
  }

  function set_valign(valign: TextVAlign): TextVAlign {
    this.valign = valign;
    redo();
    return valign;
  }

  public function new(text: String, font: String, size: Float, color: UInt) {
    super();

    tfield = new TextField();
    addChild(tfield);
    tfield.selectable = false;
    // tfield.antiAliasType = flash.text.AntiAliasType.ADVANCED;
    // tfield.gridFitType = flash.text.GridFitType.SUBPIXEL;
    tfield.mouseEnabled = false;
    tfield.multiline = true;
    tfield.autoSize = openfl.text.TextFieldAutoSize.LEFT;
    format = new TextFormat();
    format.kerning = true;

    this.text = text;
    this.size = size;
    this.font = font;
    this.bold = false;
    this.color = color;
    redo();
  }

  public function redo() {
    tfield.setTextFormat(format);
    tfield.x = switch(align) {
      case LEFT: 0;
      case CENTER: -tfield.textWidth/2.0;
      case RIGHT: -tfield.textWidth;
    }
    tfield.y = switch(valign) {
      case TOP: 0;
      case MIDDLE: -tfield.textHeight/2.0;
      case BOTTOM: -tfield.textHeight;
    }
  }
}
