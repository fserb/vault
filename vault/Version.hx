package vault;

import sys.io.Process;

class Version {
  macro static function buildDate() {
    var ret = Date.now().toString();
    return macro $v{ret};
  }

  static function getLine(cmd: String, args: Array<String>): String {
    Sys.command(cmd + " " + args.join(" ") + " > .tmp.vault.version");
    var f = sys.io.File.getContent(".tmp.vault.version");
    Sys.command("rm -f .tmp.vault.version");
    return StringTools.trim(f);
  }

  macro static function getGitVersion() {
    var name = getLine("git", ["rev-parse", "--abbrev-ref", "HEAD"]);
    var ver = getLine("git", ["describe", "--always"]);
    var ret = ver + "/" + name;
    return macro $v{ret};
  }

  static public function version(): String {
    return buildDate() + " - " + getGitVersion();
  }
}
