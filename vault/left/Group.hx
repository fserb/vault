package vault.left;

import vault.left.Object;
import vault.left.View;

class Group extends Object {
  var members: Array<Object>;

  public function new() {
    members = new Array<Object>();
  }

  public function add(obj: Object) {
    members.push(obj);
  }

  public function remove(obj: Object) {
    members.remove(obj);
  }

  override public function update() {
    for (m in members) {
      if (!m.dead) {
        Left.profile.objectCount++;
        m.update();
      } else {
        members.remove(m);
      }
    }
  }

  public function sort(key: Dynamic -> Float) {
    members.sort(function(a, b) {
      var ka = key(a);
      var kb = key(b);
      if (ka < kb) return -1;
      if (ka > kb) return 1;
      return 0;
    });
  }

  override public function render(vp: View) {
    for (m in members) {
      if (!m.dead && m.visible) {
        m.render(vp);
      }
    }
  }
}
