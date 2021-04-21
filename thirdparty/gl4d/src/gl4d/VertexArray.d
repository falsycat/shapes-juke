/// License: MIT
module gl4d.VertexArray;

import std.conv,
       std.typecons;

import gl4d.gl,
       gl4d.math,
       gl4d.Buffer,
       gl4d.GLObject;

/// RefCounted version of VertexArray.
alias VertexArrayRef = RefCounted!VertexArray;

/// A wrapper type for OpenGL vertex array.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct VertexArray {
  mixin GLObject!(
      (x, y) => gl.GenVertexArrays(x, y),
      (x)    => gl.BindVertexArray(x),
      (x)    => gl.DeleteVertexArrays(1, x)
    );

 public:
  ~this() {
    // Forces unrefering all buffers.
    foreach (key; attachments_.keys) {
      attachments_[key] = ArrayBufferRef.init;
    }
  }

 private:
  ArrayBufferRef[int] attachments_;
}

/// An attacher between array buffers and vertex arrays.
struct VertexArrayAttacher {
 public:
  ///
  int index;
  ///
  GLenum type;
  ///
  int dimension;
  ///
  bool normalized;
  ///
  int stride;
  ///
  int offset;
  ///
  int divisor;

  /// Attaches the buffer to the vertex array with parameters this has.
  /// (The vertex array must be bound.)
  void Attach(ref VertexArrayRef va, ref ArrayBufferRef buf)
  in {
    assert(!va.empty);
    assert(!buf.empty);

    assert(index >= 0);
    assert(0 < dimension && dimension <= 4);
    assert(stride >= 0);
    assert(offset >= 0);
    assert(divisor >= 0);
  }
  do {
    va.attachments_[index] = buf;

    buf.Bind();

    const i = index.to!GLuint;
    gl.EnableVertexAttribArray(i);

    gl.VertexAttribPointer(
        i, dimension.to!GLint,
        type, normalized, stride.to!GLsizei,
        cast(GLvoid*) offset.to!ptrdiff_t);

    gl.VertexAttribDivisor(i, divisor.to!GLuint);
  }
}
