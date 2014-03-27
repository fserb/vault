package vault;

/*
The Cinematic class has a few entry points:
  var cm = new Cimeatic();

  Creates a script. If name is specified, script is only triggered after name.
  This can be called multiple times.
  cm.create({ ... }, [name]);

  Triggers a signal. Signals are shared through all instances of Cinematic.
  cm.trigger(signal);

  Returns true if signal has been triggered.
  cm.triggered(signal);

  To be called on ENTER_FRAME:
  cm.update();

How the Script works:

  Every execution line is always executed in parallel. Control flow is done by
  signals or sequences. All functions called by the script are Float -> Bool.
  They get the number of seconds elapsed since the begin of the event and return
  true when they are done.

  Calls a function a(t):
    a();

  Calls a function a(1, 2, t):
    a(1, 2);

  Calls a function a(t) together with b(t):
    a();
    b();

  Calls a function a(t) and then b(t) when a is over.
    a() > b();

  Delays execution for 10 seconds:
    10;

  Calls a function a(t) after 3 seconds:
    3 > a();

  Calls a function a(t) with Exponential ease in for 3 seconds:
    a() << EaseIn(3);

  triggers a signal hello:
    [ ! hello ];

  waits for signal "hi":
    [ hi ];

  tweens variable x to 100:
    x % 100

  Calls a(t), waits for 3 seconds, triggers 'sig1'. Waits for 'sig1' to trigger
  b(t) with 4s quadratic ease (that the triggers 'sig2') and c(t).
    a() > 3 > [!sig1];
    [sig1] > b() << QuadIn(4) >> [sig2];
    [sig1] > c();
*/

#if !macro
import vault.Ease;
#end

import haxe.macro.Expr;

typedef CinematicEvent = {
  // f(elapsed time) -> returns true if done.
  var func: Float -> Bool;
  // start time of this event.
  var start: Float;
  // next event to be triggered.
  var next: CinematicEvent;
}

class Cinematic {
  #if !macro
  var events: Array<CinematicEvent>;
  var signals: Map<String, Bool>;
  var speed: Float = 1.0;
  var paused: Bool = false;
  #end
  static public var registers = new Array<Null<Float>>();

  public function new() {
    #if !macro
    reset();
    #end
  }

  macro public function create(ethis: Expr, block: Expr, ?trigger: String = null, ?mustdebug:Bool = false): Expr {
    // parse the script into a series of functions, separated sequences by >
    var commands = eval(ethis, block, trigger);
    if (mustdebug) {
      debug(commands);
    }
    // translate sequences into proper class commands.
    var actions = makeActions(ethis, commands);
    // debug(actions);
    return macro {
      $actions;
    }
  }

#if macro
  static function error( ?msg="", p : Position ) {
    haxe.macro.Context.error("Macro error: "+msg, p);
    return null;
  }

  static function debug(block: Expr) {
    trace((new haxe.macro.Printer()).printExpr(block));
  }

  static function unpackConst(e:Expr): String {
    return switch(e.expr) {
      case EConst(c):
        switch(c) {
          case CIdent(v): v;
          case CString(v): v;
          case CInt(v): v;
          case CFloat(v): v;
          default: null;
        }
      default: null;
    }
  }

  static function evalEase(ethis: Expr, left: Expr, right: Expr) : Expr {
    var name: String;
    var time;
    switch(right.expr) {
      case ECall(funcname, params):
        name = unpackConst(funcname);
        time = params[0];
      default: error("Invalid easing: " + right, right.pos);
    }

    var func = eval(ethis, left);

    return macro function(t: Float): Bool {
      var v = Math.min(1.0, t/${time});
      (${func})(vault.Ease.$name(v));
      return v >= 1.0;
    };
  }

  static function eval(ethis: Expr, block: Expr, ?trigger: String = null): Expr {
    switch (block.expr) {
      case EBlock(elems):
        var exprs = [];
        for (e in elems) {
          if (trigger != null) {
            e = macro [ $v{trigger} ] > $e;
          }
          exprs.push(eval(ethis, e));
        }
        return macro { $a{exprs} };

      case EConst(c):
        switch(c) {
          case CInt(v):
            return macro function (t: Float): Bool { return t > $v{Std.parseInt(v)}; };
          case CFloat(v):
            return macro function (t: Float): Bool { return t > $v{Std.parseFloat(v)}; };
          case CIdent(v):
            return macro function (t: Float): Bool { return t > $i{v}; };
          default:
            trace(c);
            return null;
        }
        return null;

      case ECall(funcname, funcargs):
        funcargs.push(macro t);
        return macro function (t: Float): Bool { return $funcname($a{funcargs}); };

      case EFunction(_, _):
        return block;

      case EBinop(op, left, right):
        switch(op) {
          case OpShl:
            return evalEase(ethis, left, right);
          case OpGt:
            var l = eval(ethis, left);
            var r = eval(ethis, right);
            return macro $l > $r;
          case OpMod:
            var l = registers.length;
            registers.push(null);
            // this "t == 0" is a hack, since it's really hard to detect the beginning of an event.
            return macro function(t:Float): Bool {
              if (vault.Cinematic.registers[$v{l}] == null || t == 0) {
                vault.Cinematic.registers[$v{l}] = $left;
              }
              $left = vault.Cinematic.registers[$v{l}] + (($right) - vault.Cinematic.registers[$v{l}])*t;
              return t >= 1;
            };
          default: trace(op); trace(left); trace(right); return block;
        }

      case EArrayDecl(els):
        switch (els[0].expr) {
          case EConst(c):
            var signal = unpackConst(els[0]);
            return macro function(t: Float) { return $ethis.triggered($v{signal}); };
          case EUnop(op, _, c):
            var signal = unpackConst(c);
            return macro function(s: Float) { $ethis.trigger($v{signal}); return true; };
          default:
            return error("Signal can only be sent (!) or received", block.pos);
        }
        return error("Only one signal can be sent or received", block.pos);

      case EParenthesis(e):
        return eval(ethis, e);

      default: trace(block.expr); return block;
    }
  }

  static function makeActions(ethis: Expr, block: Expr): Expr {
    switch (block.expr) {
      case EBlock(elems):
        var exprs = [];
        for (e in elems) {
          exprs.push(macro $ethis.beginAction());
          exprs.push(makeActions(ethis, e));
        }
        return macro { $a{exprs} };

      case EBinop(op, left, right):
        switch(op) {
          case OpGt:
            var l = makeActions(ethis, left);
            var r = makeActions(ethis, right);
            return macro { $l; $r; };

          default: trace("ACT: " + block.expr); return block;
        }

      case EFunction(_, _):
        return macro $ethis.addAction($block);

      case ECall(_):
        return macro $ethis.addAction($block);

      default: trace("ACT: " + block.expr); return block;
    }
  }
#end

#if !macro
  static var currentEvent: CinematicEvent;

  public inline function beginAction() {
    currentEvent = null;
  }

  public inline function addAction(func: Float -> Bool): CinematicEvent {
    var ev:CinematicEvent = { func: func, start: 0, next: null };
    if (currentEvent == null) {
      events.push(ev);
      currentEvent = ev;
    } else {
      currentEvent.next = ev;
      currentEvent = ev;
    }
    return ev;
  }

  public function setSpeed(speed: Float) {
    this.speed = speed;
  }

  public function pause() {
    this.paused = true;
  }

  public function resume() {
    this.paused = false;
  }

  public function triggered(signal: String) {
    return signals.exists(signal) && signals[signal];
  }

  public function trigger(signal: String) {
    signals[signal] = true;
  }

  public function release(signal: String) {
    signals[signal] = false;
  }

  public function done(): Bool {
    return events.length == 0;
  }

  public function reset() {
    events = [];
    signals = new Map<String, Bool>();
  }

  var lastTimer: Float;
  public function update() {
    var newevents = new Array<CinematicEvent>();
    for (e in events) {
      if (!paused) {
        lastTimer = haxe.Timer.stamp();
      }
      if (e.start == 0) {
        e.start = lastTimer;
      }
      var t = (lastTimer - e.start) * speed;
      if (e.func(t)) {
        var ev = e.next;
        while(ev != null) {
          ev.start = lastTimer;
          if (ev.func(0)) {
            ev = ev.next;
          } else {
            newevents.push(ev);
            break;
          }
        }
      } else {
        newevents.push(e);
      }
    }
    events = newevents;
  }
#end
}
