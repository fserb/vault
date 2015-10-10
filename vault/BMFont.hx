package vault;

import vault.geom.Vec2;

class BMChar {
  public var x: Int;
  public var y: Int;
  public var width: Int;
  public var height: Int;
  public var xoffset: Int;
  public var yoffset: Int;
  public var xadvance: Int;

  public function new(copy: BMChar = null) {
    if (copy != null) {
      x = copy.x;
      y = copy.y;
      width = copy.width;
      height = copy.height;
      xoffset = copy.xoffset;
      yoffset = copy.yoffset;
      xadvance = copy.xadvance;
    }
  };
}

class BMFont {
  public var face: String;
  public var size: Int;
  public var lineHeight: Int;
  public var baseline: Int;
  public var chars: Map<Int, BMChar>;

  function new() {
    chars = new Map<Int, BMChar>();
  }

  static public function read(file: String): BMFont {
    var font = new BMFont();
    for (l in file.split('\n')) {
      var i = l.indexOf(" ");
      var cmd = l.substr(0, i);
      var args = new Map<String, String>();
      var st = l.substr(i+1) + "\n";
      var re = new EReg("(.*?)=(\".*?\"|.*?)[ \n]", "");
      while (re.match(st)) {
        args[re.matched(1)] = re.matched(2);
        st = re.matchedRight();
      }
      switch(cmd) {
        case "info":
          font.face = args["face"];
          font.size = Std.parseInt(args["size"]);
        case "common":
          font.lineHeight = Std.parseInt(args["lineHeight"]);
          font.baseline = Std.parseInt(args["base"]);
        case "char":
          var c = new BMChar();
          c.x = Std.parseInt(args["x"]);
          c.y = Std.parseInt(args["y"]);
          c.width = Std.parseInt(args["width"]);
          c.height = Std.parseInt(args["height"]);
          c.xoffset = Std.parseInt(args["xoffset"]);
          c.yoffset = Std.parseInt(args["yoffset"]);
          c.xadvance = Std.parseInt(args["xadvance"]);
          font.chars[Std.parseInt(args["id"])] = c;
      }
    }

    return font;
  }
}
