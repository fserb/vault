package vault.algo;

// D* Lite implementation

using Lambda;

import vault.Base;
import vault.ds.PriorityQueue;

typedef MapNode = {
  // actual distance from the goal.
  var g: Int;
  // estimated distance based on neighbours.
  var rhs: Int;
  // if g == rhs then the node is stable.

  // position.
  var x: Int;
  var y: Int;
  // cost.
  var cost: Int;
}

class DLiteMap {
  public inline static var INF:Int = 0x3FFFFFFF;
  // min priority queue containing the set of open nodes.
  var open: PriorityQueue<MapNode, Pair<Int, Int>>;
  //
  var km: Int;
  // goal and start nodes.
  var goal: MapNode;
  var start: MapNode;
  var last_start: MapNode;
  var update_cost: Bool;

  var width: Int;
  var height: Int;

  // map.
  var array:Array<Array<MapNode>>;

  public function new(width:Int, height:Int, xgoal: Int, ygoal: Int) {
    this.width = width;
    this.height = height;
    array = new Array<Array<MapNode>>();
    for (x in 0...width) {
      var col = new Array<MapNode>();
      for (y in 0...height) {
        col.push({ x: x, y: y,
                   cost: 1,
                   g: INF,
                   rhs: INF });
      }
      array.push(col);
    }
    open = new PriorityQueue<MapNode, Pair<Int, Int>>();
    km = 0;
    goal = get(xgoal, ygoal);
    last_start = null;
    update_cost = true;
  }

  public function setStart(x: Int, y: Int) {
    start = get(x, y);
  }

  public function setCost(x: Int, y: Int, cost: Int) {
    var n = get(x, y);
    var cold = n.cost;
    if (cost >= 0) {
      n.cost = cost;
    } else {
      n.cost = INF;
    }
    if (n.cost == cold) {
      return;
    }
    if (last_start == null) {
      return;
    }
    var minv = succ(n).fold(function(s, acc) return EMath.min(acc, s.g), INF);
    if (cold > n.cost) {
      if (n != goal) {
        n.rhs = EMath.min(n.rhs, cost + minv);
      }
    } else if (n.rhs == cold + minv) {
      if (n != goal) {
        n.rhs = cost + minv;
      }
    }
    updateVertex(n);
    update_cost = true;
  }

  inline function get(x: Int, y: Int):MapNode {
    return array[x][y];
  }

  /**
   *  Returns the list of neighbours of a node.
   *  @params a map node.
   *  @returns list of neighbours.
   **/
  inline function succ(a:MapNode, self:Bool=false): List<MapNode> {
    var ret = new List<MapNode>();
    if (a.x > 0)          ret.add(get(a.x - 1, a.y));
    if (a.x < width - 1)  ret.add(get(a.x + 1, a.y));
    if (a.y > 0)          ret.add(get(a.x, a.y - 1));
    if (a.y < height - 1) ret.add(get(a.x, a.y + 1));
    if (self)             ret.add(a);
    return ret;
  }

  /**
   *  Computes the Manhattan distance between @n and start.
   *  This is used as an estimate of the score, to decide in which direction
   *    to expand to.
   *  @param n map node to estimate to.
   *  @return Manhattan distance between n and start.
   */
  inline function h(n:MapNode):Int {
    return Math.round(Math.abs(start.x - n.x) + Math.abs(start.y - n.y));
  }

  /**
   *  Calculates the Priority Queue priority of @n.
   *  The priority contains two values that are compared in order.
   *  The first is the estimate of g, the second is the current best
   *    available g.
   *  We always use the smallest possible value of the estimate, so we never
   *    have to backtrack (i.e., nodes that affect other nodes need to be
   *    visited first.
   *  @param n Map node
   *   @returns Priority [ estimate, available ]
   */
  function calculateKey(n:MapNode):Pair<Int, Int> {
    return new Pair(EMath.min(n.g, n.rhs) + h(n) + km,
                    EMath.min(n.g, n.rhs));
  }

  function updateVertex(u:MapNode) {
    var idx = open.find(function(n) return n == u);
    if (idx >= 0) {
      open.remove(idx);
    }
    if (u.g != u.rhs) {
      open.push(u, calculateKey(u));
    }
  }

  function computeShortestPath() {
    goal.rhs = 0;
    open.push(goal, calculateKey(goal));

    while (Pair.compare(open.peekPriority(), calculateKey(start)) < 0 ||
           start.rhs > start.g) {
      var kold = open.peekPriority();
      var u = open.pop();
      var knew = calculateKey(u);
      //trace(u.x + ", " + u.y + " c:" + u.cost + " g:" + u.g + " rhs:" + u.rhs + " k:" + kold + " / " + knew);
      if (Pair.compare(kold, knew) < 0) {
        open.push(u, knew);
      } else if (u.g > u.rhs) {
        u.g = u.rhs;
        for (s in succ(u)) {
          if (s != goal) {
            s.rhs = EMath.min(s.rhs, u.g + s.cost);
          }
          updateVertex(s);
        }
      } else {
        var gold = u.g;
        u.g = INF;
        for (s in succ(u, true)) {
          var cost = s == u ? 0 : s.cost;
          if (s.rhs == gold + cost) {
            if (s != goal) {
              s.rhs = succ(s).fold(
                function(n, acc) return EMath.min(acc, n.cost + n.g), INF);
            }
          }
          updateVertex(s);
        }
      }
    }
  }

  public function getNextFrom(x: Int, y: Int): Pair<Int, Int> {
    start = get(x, y);
    if (last_start != null) {
      km = km + h(last_start);
    }
    last_start = start;
    if (update_cost) {
      computeShortestPath();
    }

    var next:MapNode = succ(start).fold(function(n:MapNode, u:MapNode) return n.g < u.g ? n : u, start);
    return new Pair(next.x, next.y);
  }

  public function printG() {
    var s = "\n";
    for (y in 0...height) {
      for (x in 0...width) {
        if (array[x][y].g == INF) {
          s += "-- ";
        } else if (array[x][y].g < 10) {
          s += " " + array[x][y].g + " ";
        } else {
          s += array[x][y].g + " ";
        }
      }
      s += "\n";
    }
    return s;
  }

  public function printC() {
    var s = "\n";
    for (y in 0...height) {
      for (x in 0...width) {
        if (array[x][y].cost == INF) {
          s += "-- ";
        } else if (array[x][y].cost < 10) {
          s += " " + array[x][y].cost + " ";
        } else {
          s += array[x][y].cost + " ";
        }
      }
      s += "\n";
    }
    return s;
  }

}
