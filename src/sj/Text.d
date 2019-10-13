/// License: MIT
module sj.Text;

import std.conv,
       std.exception;

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
    indices_  = ElementArrayBuffer.Create();

    program_.SetupVertexArray(vao_, vertices_);
  }

  ///
  float LoadGlyphs(vec2i texsz, dstring text, vec2i charsz, FaceRef face)
      in (texsz.x > 0 && texsz.y > 0) {
    static assert(TextProgram.Vertex.sizeof == float.sizeof * 5);

    vertices_.Bind();
    ArrayBufferAllocator vertices_allocator;
    with (ArrayBufferAllocator()) {
      size  = text.length * TextProgram.Vertex.sizeof * 4;
      usage = GL_STATIC_DRAW;
      Allocate(vertices_);
    }
    auto vertices_data = vertices_.MapToWrite!float;
    auto vertices_ptr  = vertices_data.entity;
    auto pixels        = new ubyte[texsz.x * texsz.y];

    GlyphLoader gloader;
    gloader.pxWidth  = charsz.x;
    gloader.pxHeight = charsz.y;
    gloader.flags    = FT_LOAD_DEFAULT | FT_LOAD_RENDER;

    model_width_ = 0;
    int    bmp_width;
    size_t glyph_count;
    foreach (c; text) {
      if (c == ' ') continue;

      with (gloader) {
        character = c;
        Load(face).enforce;
      }
      const bitmap = face.EnforceGlyphBitmap();
      const srcsz  = vec2i(bitmap.width, bitmap.rows);
      CopyRawPixels(bitmap.buffer, srcsz, pixels.ptr, texsz, vec2i(bmp_width, 0));

      const m         = &face.glyph.metrics;
      const bearing_x = m.horiBearingX*1f / m.width  * srcsz.x;
      const bearing_y = m.horiBearingY*1f / m.height * srcsz.y;
      const advance   = m.horiAdvance *1f / m.width  * srcsz.x;

      const posleft   = model_width_ + bearing_x;
      const posright  = posleft + srcsz.x;
      const postop    = bearing_y;
      const posbottom = postop - srcsz.y;

      const uvleft   = bmp_width*1f / texsz.x;
      const uvright  = (bmp_width + srcsz.x)*1f / texsz.x;
      const uvtop    = 0f;
      const uvbottom = srcsz.y*1f / texsz.y;

      *vertices_ptr++ = posleft;
      *vertices_ptr++ = postop;
      *vertices_ptr++ = 0;
      *vertices_ptr++ = uvleft;
      *vertices_ptr++ = uvtop;

      *vertices_ptr++ = posleft;
      *vertices_ptr++ = posbottom;
      *vertices_ptr++ = 0;
      *vertices_ptr++ = uvleft;
      *vertices_ptr++ = uvbottom;

      *vertices_ptr++ = posright;
      *vertices_ptr++ = postop;
      *vertices_ptr++ = 0;
      *vertices_ptr++ = uvright;
      *vertices_ptr++ = uvtop;

      *vertices_ptr++ = posright;
      *vertices_ptr++ = posbottom;
      *vertices_ptr++ = 0;
      *vertices_ptr++ = uvright;
      *vertices_ptr++ = uvbottom;

      bmp_width    += srcsz.x;
      model_width_ += advance;
      ++glyph_count;
    }

    texture_.Bind();
    Texture2DAllocator texture_allocator;
    with (texture_allocator) {
      level          = 0;
      internalFormat = GL_RGBA8;
      data           = pixels.ptr;
      size           = texsz;
      format         = GL_RED;
      type           = GL_UNSIGNED_BYTE;
      Allocate(texture_);
    }

    indices_.Bind();
    ElementArrayBufferAllocator indices_allcator;
    with (indices_allcator) {
      size  = glyph_count * 6 * ushort.sizeof;
      usage = GL_STATIC_DRAW;
      Allocate(indices_);
    }
    auto indices_data = indices_.MapToWrite!ushort;
    auto indices_ptr  = indices_data.entity;

    ushort vertex_count;
    foreach (i; 0..glyph_count) {
      *indices_ptr++ = vertex_count;
      *indices_ptr++ = vertex_count++;

      *indices_ptr++ = vertex_count++;
      *indices_ptr++ = vertex_count++;

      *indices_ptr++ = vertex_count;
      *indices_ptr++ = vertex_count++;
    }
    index_count_ = indices_ptr - indices_data.entity;

    return model_width_;
  }

  ///
  void Clear() {
    index_count_ = 0;
  }

  ///
  void Draw(mat4 proj, mat4 view) {
    if (index_count_ == 0) return;

    program_.Use(proj, view, matrix.Create(), texture_, color);

    vao_.Bind();
    indices_.Bind();
    gl.DrawElements(GL_TRIANGLE_STRIP, index_count_.to!int, GL_UNSIGNED_SHORT, null);
  }

  ///
  @property float modelWidth() const {
    return model_width_;
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

  ElementArrayBufferRef indices_;

  size_t index_count_;

  float model_width_;
}
