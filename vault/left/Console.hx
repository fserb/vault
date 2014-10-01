package vault.left;

import haxe.Timer;

class Profile {
  public var updateTime: Float = 0.0;
  public var renderTime: Float = 0.0;
  public var renderTiles: Int = 0;
  public var renderDraw: Int = 0;

  public var objectCount: Int = 0;

  public var time: Float = 0.0;

  public function mark(): Float {
    var n = Timer.stamp();
    var ret = n - time;
    time = n;
    return Math.round(ret*10000)/10;
  }

  public function average(oldv: Float, newv: Float): Float {
    return Math.round( ((9*oldv + newv)/10)*10)/10.0;
  }

  public function new() {
    Left.console.watch(this, "updateTime", "time.update");
    Left.console.watch(this, "renderTime", "time.render");
    Left.console.watch(this, "renderTiles", "render.drawTiles");
    Left.console.watch(this, "renderDraw", "render.drawSprites");
    Left.console.watch(this, "objectCount", "engine.objects");
  }

  public function update() {
    renderTiles = 0;
    renderDraw = 0;
    objectCount = 1;
  }
}

typedef WatchVariable = {
  name: String,
  instance: Dynamic,
  variable: String,
};
typedef OneVariable = {
  name: String,
  value: Dynamic,
};

class Console {
  var logfile: sys.io.FileOutput;
  var watchlist: Array<WatchVariable>;
  var onelist: Array<OneVariable>;

  public function new() {
    logfile = sys.io.File.write("console.log", false);
    watchlist = [];
    onelist = [];
  }

  public function one(name: String, value: Dynamic) {
    onelist.push({name:name, value:value});
  }

  public function watch(instance: Dynamic, variable: String, name: String = null) {
    if (name == null) {
      name = Type.getClassName(instance) + "." + variable;
    }
    watchlist.push({instance: instance, variable: variable, name: name});
  }

  function makeline(name: String, value: String, namesize: Int): String {
    var s = "\x1B[1;30m" + name;
    for (c in 0...(namesize - name.length)) s += " ";
    s += " :\x1B[0;37m " + value + "\n";
    return s;
  }

  public function update() {
    logfile.writeString("\x1B[2J\x1B[0;0H");
    var namesize = 0;
    for (w in watchlist) {
      namesize = EMath.max(namesize, w.name.length);
    }
    for (o in onelist) {
      namesize = EMath.max(namesize, o.name.length);
    }

    for (w in watchlist) {
      logfile.writeString(makeline(w.name,
        Reflect.getProperty(w.instance, w.variable), namesize));
    }
    for (o in onelist) {
      logfile.writeString(makeline(o.name, o.value, namesize));
    }

    logfile.flush();
  }
}
