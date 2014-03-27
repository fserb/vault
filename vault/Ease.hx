package vault;

typedef EaseFunction = Float -> Float;

class Ease {
	public static inline function linear(t:Float):Float { return t; }

	public static inline function reverse(t:Float):Float { return 1-t; }

	public static inline function hold(t:Float): Float { return 1; }

	public static inline function quadIn(t:Float):Float {
		return t*t;
	}
	public static inline function quadOut(t:Float):Float {
		return -t*(t-2);
	}
	public static inline function quadInOut(t:Float):Float {
    if (t < 0.5) {
    	return t*t*2;
  	} else {
  		return  -2*t*t + 4*t -1.0;
  	}
  }

	public static inline function cubicIn(t:Float):Float {
		return t*t*t;
	}
	public static inline function cubicOut(t:Float):Float {
		return (t-1)*(t-1)*(t-1) + 1;
	}
	public static inline function cubicInOut(t:Float):Float {
		if (t < 0.5) {
			// 1/2*t*t*t
			return t*t*t*4;
		} else {
			var f = (2*t)-2;
			return 0.5*f*f*f + 1;
		}
	}

	public static inline function quartIn(t:Float):Float {
    return t * t * t * t;
	}
	public static inline function quartOut(t:Float):Float {
    var f = (t - 1);
    return f * f * f * (1 - t) + 1;
	}
	public static inline function quartInOut(t:Float):Float {
    if(t < 0.5) {
      return 8 * t * t * t * t;
 	  } else {
      var f = (t - 1);
	    return -8 * f * f * f * f + 1;
    }
  }

  public static inline function quintIn(t:Float):Float {
  	return t*t*t*t*t;
  }
  public static inline function quintOut(t:Float):Float {
		var f = (t - 1);
    return f * f * f * f * f + 1;
	}
	public static inline function quintInOut(t:Float):Float {
    if(t < 0.5) {
    	return 16 * t * t * t * t * t;
    } else {
      var f = (2 * t) - 2;
      return  0.5 * f * f * f * f * f + 1;
    }
  }

  public static inline function sinIn(t:Float):Float {
  	return Math.sin((t - 1) * Math.PI/2) + 1;
  }
  public static inline function sinOut(t:Float):Float {
  	return Math.sin(t * Math.PI/2);
  }
  public static inline function sinInOut(t:Float):Float {
    return 0.5 * (1 - Math.cos(t * Math.PI));
  }

  public static inline function expIn(t:Float):Float {
    return (t == 0.0) ? 0.0 : Math.pow(2, 10 * (t - 1));
  }
  public static inline function expOut(t:Float):Float {
    return (t == 1.0) ? 1.0 : 1 - Math.pow(2, -10 * t);
	}
  public static function expInOut(t:Float):Float {
    if (t == 0.0 || t == 1.0) return t;
    if (t < 0.5) {
      return 0.5 * Math.pow(2, (20 * t) - 10);
    } else {
    	return -0.5 * Math.pow(2, (-20 * t) + 10) + 1;
    }
  }

	public static inline function circIn(t:Float):Float {
		return 1 - Math.sqrt(1 - (t * t));
	}
	public static inline function circOut(t:Float):Float {
		return Math.sqrt((2 - t) * t);
	}
	public static inline function circInOut(t:Float):Float {
		if(t < 0.5) {
			return 0.5 * (1 - Math.sqrt(1 - 4 * (t * t)));
    } else {
    	return 0.5 * (Math.sqrt(-((2 * t) - 3) * ((2 * t) - 1)) + 1);
    }
  }

  // c,d=1 b=0

  public static inline function backIn(t:Float):Float {
    return t * t * t - t * Math.sin(t * Math.PI);
  	// return t*t*((1.70158+1)*t - 1.70158);
  }
  public static inline function backOut(t:Float):Float {
    var f = (1 - t);
    return 1 - (f * f * f - f * Math.sin(f * Math.PI));
    // if (s == undefined) s = 1.70158;
    // return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
  }
  public static inline function backInOut(t:Float):Float {
    if(t < 0.5) {
    	var f = 2*t;
			return 0.5 * (f * f * f - f * Math.sin(f * Math.PI));
    } else {
      var f = (1 - (2*t - 1));
      return 0.5 * (1 - (f * f * f - f * Math.sin(f * Math.PI))) + 0.5;
    }
  }

	public static inline function elasticIn(t:Float):Float {
		return Math.sin(13 * t * Math.PI/2) * Math.pow(2, 10 * (t - 1));
	}
	public static inline function elasticOut(t:Float):Float {
    return Math.sin(-13 * (t + 1) * Math.PI/2) * Math.pow(2, -10 * t) + 1;
	}
	public static inline function elasticInOut(t:Float):Float {
    if(t < 0.5) {
      return 0.5 * Math.sin(13 * (2 * t) * Math.PI/2) * Math.pow(2, 10 * ((2 * t) - 1));
    } else {
      return 0.5 * (Math.sin(-13 * ((2 * t - 1) + 1) * Math.PI/2) * Math.pow(2, -10 * (2 * t - 1)) + 2);
    }
	}

	public static inline function bounceIn(t:Float):Float {
    return 1 - bounceOut(1 - t);
	}

	public static inline function bounceOut(t:Float):Float {
    if(t < 4/11.0) {
      return (121 * t * t)/16.0;
    } else if(t < 8/11.0) {
      return (363/40.0 * t * t) - (99/10.0 * t) + 17/5.0;
    } else if(t < 9/10.0) {
      return (4356/361.0 * t * t) - (35442/1805.0 * t) + 16061/1805.0;
    } else {
      return (54/5.0 * t * t) - (513/25.0 * t) + 268/25.0;
    }
	}
	public static inline function BounceEaseInOut(t:Float):Float {
    if(t < 0.5) {
      return 0.5 * bounceIn(t*2);
    } else {
      return 0.5 * bounceOut(t * 2 - 1) + 0.5;
    }
	}
}
  /**
   * Operation of in/out easers:
   *
   * in(t)
   *    return t;
   * out(t)
   *    return 1 - in(1 - t);
   * inOut(t)
   *    return (t <= .5) ? in(t * 2) / 2 : out(t * 2 - 1) / 2 + .5;
   */
