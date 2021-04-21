/// License: MIT
module gl4d.Texture;

import std.conv,
       std.typecons;

import gl4d.gl,
       gl4d.math,
       gl4d.GLObject;

///
alias Texture2D = Texture!GL_TEXTURE_2D;
/// RefCounted version of Texture2D.
alias Texture2DRef = TextureRef!GL_TEXTURE_2D;
///
alias Texture2DAllocator = TextureAllocator!GL_TEXTURE_2D;
///
alias Texture2DOverwriter = TextureOverwriter!GL_TEXTURE_2D;

///
alias TextureRect = Texture!GL_TEXTURE_RECTANGLE;
/// RefCounted version of TextureRect.
alias TextureRectRef = TextureRef!GL_TEXTURE_RECTANGLE;
///
alias TextureRectAllocator = TextureAllocator!GL_TEXTURE_RECTANGLE;
///
alias TextureRectOverwriter = TextureOverwriter!GL_TEXTURE_RECTANGLE;

/// RefCounted version of Texture.
template TextureRef(GLenum target) {
  alias TextureRef = RefCounted!(Texture!target);
}

/// A wrapper type for OpenGL texture.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct Texture(GLenum target_) {
  mixin GLObject!(
      (x, y) => gl.GenTextures(x, y),
      (x)    => gl.BindTexture(target_, x),
      (x)    => gl.DeleteTextures(1, x)
    );
 public:
  ///
  enum target = target_;

  /// Binds this texture to the texture unit.
  ///
  /// This texture will be bound.
  void BindToUnit(GLenum unit) {
    assert(!empty);
    gl.ActiveTexture(unit);
    Bind();
  }

  /// Generates mipmaps of this texture.
  ///
  /// This texture must be bound.
  void GenerateMipmap() {
    assert(!empty);
    gl.GenerateMipmap(target_);
  }
}

/// An allocator for 2D textures.
struct TextureAllocator(GLenum target)
  if (target.IsSupported2DTextureTarget()) {
 public:
  ///
  int level;
  ///
  GLint internalFormat;
  ///
  vec2i size;
  ///
  GLint border;
  ///
  GLenum format;
  ///
  GLenum type;
  ///
  const(void)* data;

  /// Allocates the texture with parameters this has.
  ///
  /// The texture will be bound.
  void Allocate(ref TextureRef!target texture)
  in {
    assert(!texture.empty);

    assert(level >= 0);
    assert(size.x > 0 && size.y > 0);
    assert(border == 0);
  }
  do {
    texture.Bind();
    gl.TexImage2D(target, level.to!GLint, internalFormat,
        size.x.to!GLsizei, size.y.to!GLsizei, border, format, type, data);
  }
}

/// An overwriter for 2D textures.
struct TextureOverwriter(GLenum target)
  if (target.IsSupported2DTextureTarget()) {
 public:
  ///
  int level;
  ///
  vec2i offset;
  ///
  vec2i size;
  ///
  GLenum format;
  ///
  GLenum type;
  ///
  const(void)* data;

  /// Overwrites the texture with parameters this has.
  ///
  /// The texture will be bound.
  void Overwrite(ref TextureRef!target texture)
  in {
    assert(!texture.empty);

    assert(level >= 0);
    assert(offset.x >= 0 && offset.y >= 0);
    assert(size.x > 0 && size.y > 0);

  }
  do {
    texture.Bind();
    gl.TexImage2D(target, level.to!GLint,
        offset.x.to!GLint, offset.y.to!GLint,
        size.x.to!GLsizei, size.y.to!GLsizei,
        format, type, data);
  }
}

/// Returns: whether the target is supported 2d texture
@property bool IsSupported2DTextureTarget(GLenum target) {
  return
    target == GL_TEXTURE_2D ||
    target == GL_TEXTURE_RECTANGLE;
}
