/// License: MIT
module sj.FontSet;

import std.file,
       std.path;

import sj.Font;

///
class FontSet {
 public:
  ///
  this() {
    const dir = thisExePath.dirName;

    gothic_heavy_ = new Font(dir~"/fonts/SourceHanSansJP-Heavy.otf");
  }
  ~this() {
    gothic_heavy_.destroy();
  }

  ///
  @property Font gothicHeavy() {
    return gothic_heavy_;
  }

 private:
  Font gothic_heavy_;
}
