package vault;

import sys.io.Process;

class Version {
  macro static function buildDate() {
    var ret = Date.now().toString();
    return macro $v{ret};
  }

  macro static function getGitVersion() {
    var name = new Process("/usr/bin/git", ["rev-parse", "--abbrev-ref", "HEAD"]).stdout.readLine();
    var ver = new Process("/usr/bin/git", ["describe", "--always"]).stdout.readLine();
    var ret = ver + "/" + name;
    return macro $v{ret};
  }

  static public function version(): String {
    return buildDate() + " - " + getGitVersion();
  }
}
