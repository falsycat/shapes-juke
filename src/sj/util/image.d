/// License: MIT
module sj.util.image;

import std.exception,
       std.math,
       std.string;

import derelict.sfml2.graphics;

import gl4d;

///
Texture2DRef CreateTextureFromBuffer(in ubyte[] buf) {
  auto img = sfImage_createFromMemory(buf.ptr, buf.length);
  scope(exit) sfImage_destroy(img);
  return img.CreateTextureFromImage();
}

///
Texture2DRef CreateTextureFromImage(sfImage* img) {
  const sz = sfImage_getSize(img);
  sz.x.isPowerOf2.enforce();
  sz.y.isPowerOf2.enforce();

  auto tex = Texture2D.Create();
  with (Texture2DAllocator()) {
    level          = 0;
    internalFormat = GL_RGBA8;
    data           = sfImage_getPixelsPtr(img);
    size           = vec2i(sz.x, sz.y);
    format         = GL_RGBA;
    type           = GL_UNSIGNED_INT_8_8_8_8;
    Allocate(tex);
  }
  return tex;
}
