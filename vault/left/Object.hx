package vault.left;

import vault.left.View;

class Object {
  public var visible: Bool = true;
  var dead: Bool = false;

  public function update() {}

  public function draw(view: View) {}

  public function destroy() {
    dead = true;
  }
}
