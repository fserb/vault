package vault;

import flash.net.SharedObject;
import flash.utils.ByteArray;
import flash.system.System;

class UUID {
  // Char codes for 0123456789ABCDEF
  static private var ALPHA_CHAR_CODES : Array<Dynamic> =
    [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];

  // From http://code.google.com/p/actionscript-uuid/
  // MIT License
  static public function get() : String {
    var so = SharedObject.getLocal("vault-uuid");
    if (so.data.uuid != null) {
      return so.data.uuid;
    }

    var buff:ByteArray = new ByteArray();
    var r:Int = Std.int(Date.now().getTime());
    buff.writeUnsignedInt(System.totalMemory ^ r);
    buff.writeInt(Math.round(haxe.Timer.stamp() * 1000) ^ r);
    buff.writeDouble(Math.random() * r);

    buff.position = 0;
    var chars : Array<Dynamic> = new Array<Dynamic>();
    for (i in 0...36) {
        chars.push(0);
    }
  var index:Int = 0;
    for (i in 0...16) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        chars[index++] = 45;
      }
      var b : Int = buff.readByte();
      chars[index++] = ALPHA_CHAR_CODES[(b & 0xF0) >>> 4];
      chars[index++] = ALPHA_CHAR_CODES[(b & 0x0F)];
    }
    var ret = "";
    for (c in chars) {
        ret += String.fromCharCode(c);
    }
    so.data.uuid = ret;
    so.flush();
    return ret;
  }
}
