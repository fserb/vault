package vault;

import openfl.Assets;

typedef Layer = {
  var name: String;
  var tile: Array<Array<Int>>;
}

class Tmx {
  public var path: String;
  public var width(default, null): Int;
  public var height(default, null): Int;
  public var layers: Array<Layer>;

  public function new(path: String) {
    this.path = path;

    var xml = Assets.getText(path);
    parseXML(xml);
  }

  public function getLayer(name: String): Layer {
    for (l in layers) {
      if (l.name == name) {
        return l;
      }
    }
    return null;
  }

  private function parseXML(xml:String) {
    var xml = Xml.parse(xml).firstElement();

    this.width = Std.parseInt(xml.get("width"));
    this.height = Std.parseInt(xml.get("height"));

    this.layers = new Array<Layer>();

    for (child in xml) {
      if (Std.string(child.nodeType) != "element") continue;
      if (child.nodeName == "layer") {
        layers.push(parseLayer(child));
      }
    }
  }

  private function parseLayer(xml: Xml): Layer {
    var name: String = xml.get("name");
    var tile = new Array<Array<Int>>();

    for (x in 0...width) {
      var ar = new Array<Int>();
      for (y in 0...height) {
        ar.push(0);
      }
      tile.push(ar);
    }

    for (child in xml) {
      if (Std.string(child.nodeType) != "element") continue;
      if (child.nodeName == "data") {
        var encoding = child.get("encoding");
        if (encoding == "csv") {
          var rows = child.firstChild().nodeValue.split("\n");
          var y = 0;
          for (row in rows) {
            row = StringTools.trim(row);
            if (row == "") continue;
            var values = row.split(",");
            for (x in 0...values.length) {
              if (values[x] == "") continue;
              tile[x][y] = Std.parseInt(values[x]);
            }
            y++;
          }
        }
      }
    }

    return {name: name, tile: tile};
  }
}
