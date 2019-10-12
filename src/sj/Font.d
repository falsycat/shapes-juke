/// License: MIT
module sj.Font;

import std.exception,
       std.format,
       std.string;

import derelict.sfml2.graphics;

import gl4d;

///
class Font {
 public:
  ///
  this(string path) {
    font_ = sfFont_createFromFile(path.toStringz).
      enforce("failed creating font from %s".format(path));
  }
  ~this() {
    sfFont_destroy(font_);
  }

  ///
  Texture2DRef Render(string text, size_t px) {
    assert(false);
  }

 private:
  sfFont* font_;
}
