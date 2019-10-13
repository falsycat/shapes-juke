/// License: MIT
module sj.Text;

import std.exception;

import gl4d, ft4d;

import sj.TextProgram;

///
class Text {
 public:
  ///
  this(TextProgram program) {
    program_ = program;

    texture_  = Texture2D.Create();
    vao_      = VertexArray.Create();
    vertices_ = ArrayBuffer.Create();

    program_.SetupVertexArray(vao_, vertices_);

    vertices_.Bind();
    ArrayBufferAllocator allocator;
    with (allocator) {
      const v = [
        -1f,  1f, 0f,  1f, 0f,
        -1f, -1f, 0f,  1f, 1f,
         1f, -1f, 0f,  0f, 1f,
         1f,  1f, 0f,  0f, 0f,
      ];
      data  = v.ptr;
      size  = v.length * v[0].sizeof;
      usage = GL_STATIC_DRAW;
      Allocate(vertices_);
    }
  }

  ///
  void LoadGlyphs(vec2i texsz, dstring text, vec2i charsz, FaceRef face)
      in (texsz.x > 0 && texsz.y > 0) {
    auto pixels = new ubyte[texsz.x * texsz.y];

    GlyphLoader gloader;
    gloader.pxWidth  = charsz.x;
    gloader.pxHeight = charsz.y;
    gloader.flags    = FT_LOAD_DEFAULT | FT_LOAD_RENDER;

    int x;
    foreach (c; text) {
      with (gloader) {
        character = c;
        Load(face).enforce;
      }

      const bitmap = face.EnforceGlyphBitmap();
      const srcsz = vec2i(bitmap.width, bitmap.rows);
      CopyRawPixels(bitmap.buffer, srcsz, pixels.ptr, texsz, vec2i(x, 0));

      x += srcsz.x;
    }

    texture_.Bind();
    Texture2DAllocator allocator;
    with (allocator) {
      level          = 0;
      internalFormat = GL_RGBA8;
      data           = pixels.ptr;
      size           = texsz;
      format         = GL_RED;
      type           = GL_UNSIGNED_BYTE;
      Allocate(texture_);
    }
    glyph_loaded_ = true;
  }

  ///
  void Draw(mat4 proj, mat4 view) {
    if (!glyph_loaded_) return;

    program_.Use(proj, view, matrix.Create(), texture_, color);

    vao_.Bind();
    gl.DrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }

  ///
  ModelMatrixFactory!4 matrix;

  ///
  vec4 color = vec4(0, 0, 0, 1);

 private:
  static void CopyRawPixels(in ubyte* src, vec2i srcsz, ubyte* dst, vec2i dstsz, vec2i offset) {
    auto srcy = 0, dsty = offset.y;
    for (; srcy < srcsz.y && dsty < dstsz.y; ++srcy, ++dsty) {
      auto srcx = 0, dstx = offset.x;
      for (; srcx < srcsz.x && dstx < dstsz.x; ++srcx, ++dstx) {
        dst[dstx + dsty * dstsz.x] = src[srcx + srcy * srcsz.x];
      }
    }
  }

  TextProgram program_;

  Texture2DRef texture_;

  VertexArrayRef vao_;

  ArrayBufferRef vertices_;

  bool glyph_loaded_ = false;
}
