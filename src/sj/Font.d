/// License: MIT
module sj.Font;

import std.array,
       std.conv,
       std.exception,
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
  vec2i[] CreateTextureUvArray(dstring str, size_t px) {
    auto glyphs = appender!(sfGlyph[]);
    glyphs.reserve(str.length);
    foreach (c; str) {
      glyphs ~= sfFont_getGlyph(font_, c, px.to!uint, false, 0f);
    }

    auto uv = appender!(vec2i[]);
    uv.reserve(str.length * 4);
    foreach (const ref g; glyphs[]) {
      const rc = &g.textureRect;

      const left   = rc.left;
      const right  = (rc.left + rc.width);
      const top    = rc.top;
      const bottom = (rc.top + rc.height);

      uv ~= [
        vec2i(left,  top),
        vec2i(left,  bottom),
        vec2i(right, bottom),
        vec2i(right, top),
      ];
    }
    return uv[];
  }

  ///
  vec2i GetTextureSize(size_t px) {
    const sz = sfTexture_getSize(
        sfFont_getTexture(font_, px.to!uint).enforce);
    return vec2i(sz.x, sz.y);
  }

  ///
  void BindTextureToUnit(GLenum unit, size_t px) {
    gl.ActiveTexture(unit);
    sfTexture_bind(sfFont_getTexture(font_, px.to!uint).enforce);
  }

 private:
  sfFont* font_;
}
