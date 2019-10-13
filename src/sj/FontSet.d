/// License: MIT
module sj.FontSet;

import ft4d;

///
class FontSet {
 public:
  ///
  enum Gothic = cast(ubyte[]) import("fonts/SourceHanSansJP-Regular.otf");

  ///
  this() {
    gothic_ = Face.CreateFromBuffer(Gothic);
  }

  ///
  @property FaceRef gothic() {
    return gothic_;
  }

 private:
  FaceRef gothic_;
}
