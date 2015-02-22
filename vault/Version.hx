package vault;

import sys.io.Process;

class Version {
  macro static function getGitVersion() {
    var name = new Process("git", ["rev-parse", "--abbrev-ref", "HEAD"]).stdout.readLine();
    var ver = new Process("git", ["describe", "--always"]).stdout.readLine();
    var ret = ver + "-" + name;
    return macro $v{ret};
  }

  static public function version(): String {
    return getGitVersion();
  }
}
