/// License: MIT
module sj.Font;

import std.conv,
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
  Texture2DRef CreateTexture(
      vec2i sz, string str, vec4 color, size_t px) {
    auto text = sfText_create().enforce;
    scope(exit) sfText_destroy(text);

    sfText_setFont(text, font_);
    sfText_setString(text, str.toStringz);
    sfText_setCharacterSize(text, px.to!uint);
    sfText_setFillColor(text, sfBlack);  // TODO: change color

    auto buf = sfRenderTexture_create(sz.x, sz.y, false).enforce;
    scope(exit) sfRenderTexture_destroy(buf);
    sfRenderTexture_drawText(buf, text, null);

    auto sftex = sfRenderTexture_getTexture(buf).enforce;

    auto tex = Texture2D.Create();
    Texture2DAllocator allocator;
    with (allocator) {
      internalFormat = GL_RGBA8;
      size           = sz;
      format         = GL_RED;
      type           = GL_UNSIGNED_BYTE;
      Allocate(tex);
    }

    gl.CopyImageSubData(
        sfTexture_getNativeHandle(sftex),
        GL_TEXTURE_2D,
        0,
        0,
        0,
        0,
        tex.id,
        GL_TEXTURE_2D,
        0,
        0,
        0,
        0,
        sz.x, sz.y, 1
      );
    return tex;
  }

 private:
  sfFont* font_;
}
