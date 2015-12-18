package vault.left;

import haxe.Timer;

class Profile {
  var regions: Map<String, Float>;

  public function average(oldv: Float, newv: Float): Float {
    return Math.round( ((9*oldv + newv)/10)*10)/10.0;
  }

  public function new() {
    regions = new Map<String, Float>();
  }

  public function start(region: String) {
    regions[region] = Timer.stamp();
  }

  public function end(region: String) {
    if (regions.exists(region)) {
      Left.console.time(region, (Timer.stamp() - regions[region])*1000);
    }
  }

  public function update() {
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

typedef TimeVariable = {
  name: String,
  value: Float,
  prev: Array<Float>,
};

class Console {
#if ((cpp || neko) && desktop)
  var logfile: sys.io.FileOutput;
#end
  var watchlist: Array<WatchVariable>;
  var onelist: Map<String, OneVariable>;
  var timelist: Map<String, TimeVariable>;
  var maxsize: Int;

  public function new() {
#if ((cpp || neko) && desktop)
    logfile = sys.io.File.write("console.log", false);
#end
    watchlist = [];
    onelist = new Map<String, OneVariable>();
    timelist = new Map<String, TimeVariable>();
    maxsize = 0;
  }

  public function one(name: String, value: Dynamic) {
    if (onelist[name] == null) {
      onelist[name] = {name:name, value:value};
      calcmaxsize();
    } else {
      onelist[name].value = value;
    }
  }

  public function watch(instance: Dynamic, variable: String, name: String = null) {
    if (name == null) {
      name = Type.getClassName(instance) + "." + variable;
    }
    calcmaxsize();
    watchlist.push({instance: instance, variable: variable, name: name});
  }

  public function time(name: String, value: Float) {
    if (timelist[name] == null) {
      timelist[name] = {name:name, value:value, prev: [value]};
      calcmaxsize();
    } else {
      timelist[name].value = value;
      timelist[name].prev.push(value);
      while (timelist[name].prev.length > 100) {
        timelist[name].prev.shift();
      }
    }
  }

  function makeline(name: String, value: String): String {
    var s = "\x1B[1;30m" + name;
    for (c in 0...(maxsize - name.length)) s += " ";
    s += " :\x1B[0;37m " + value + "\n";
    return s;
  }

  function calcmaxsize() {
    maxsize = 0;
    for (w in watchlist) {
      maxsize = EMath.max(maxsize, w.name.length);
    }
    for (o in onelist) {
      maxsize = EMath.max(maxsize, o.name.length);
    }

    for (t in timelist) {
      maxsize = EMath.max(maxsize, t.name.length);
    }
  }

  function rt(n: Float, prec: Int = 1): String {
    n = Math.round(n * Math.pow(10, prec));
    var str = ''+n;
    var len = str.length;
    if(len <= prec){
      while(len < prec){
        str = '0'+str;
        len++;
      }
      return '0.'+str;
    }
    else{
    return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
    }
  }

#if ((cpp || neko) && desktop)
  public function update() {
    logfile.writeString("\x1B[2J\x1B[0;0H");

    for (w in watchlist) {
      logfile.writeString(makeline(w.name,
        Reflect.getProperty(w.instance, w.variable)));
    }
    for (o in onelist) {
      logfile.writeString(makeline(o.name, o.value));
    }
    var tk = [];
    for (k in timelist.keys()) tk.push(k);
    tk.sort(function(a, b) return Reflect.compare(a, b));
    for (k in tk) {
      var t = timelist[k];
      var worst = 0.0;
      var average = 0.0;
      for (p in t.prev) {
        worst = Math.max(worst, p);
        average += p;
      }
      average = t.prev.length > 0 ? average / t.prev.length : 0;
      logfile.writeString(makeline(t.name,
        rt(t.value) + " - avg: " + rt(average) + " - worst: " + rt(worst)));
    }

    logfile.flush();
  }
#else
  public function update() {}
#end
}
