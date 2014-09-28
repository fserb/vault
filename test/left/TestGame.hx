import vault.left.Game;
import vault.left.Group;

class TestScene extends Group {

}

class TestGame extends Game {
  public function new() {
    super(new TestScene());
  }

  public static function main() {
    new TestGame();
  }
}
