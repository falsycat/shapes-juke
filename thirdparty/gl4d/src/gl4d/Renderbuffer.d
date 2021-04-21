/// License: MIT
module gl4d.Renderbuffer;

import std.conv,
       std.typecons;

import gl4d.gl,
       gl4d.math,
       gl4d.GLObject;

/// RefCounted version of OpenGL renderbuffer.
alias RenderbufferRef = RefCounted!Renderbuffer;

/// A wrapper type for OpenGL renderbuffer.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct Renderbuffer {
  mixin GLObject!(
      (x, y) => gl.GenRenderbuffers(x, y),
      (x)    => gl.BindRenderbuffer(GL_RENDERBUFFER, x),
      (x)    => gl.DeleteRenderbuffers(1, x)
    );
}

/// An allocator for OpenGL renderbuffers.
struct RenderbufferAllocator {
 public:
  ///
  GLenum format;
  ///
  vec2i size;

  /// Allocates the renderbuffer's storage with parameters this has.
  ///
  /// The renderbuffer will be bound automatically.
  void Allocate(ref RenderbufferRef rb)
  in {
    assert(!rb.empty);
  }
  do {
    rb.Bind();
    gl.RenderbufferStorage(GL_RENDERBUFFER,
        format, size.x.to!GLsizei, size.y.to!GLsizei);
  }
}
