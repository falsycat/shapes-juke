/// License: MIT
module gl4d.Buffer;

import std.conv,
       std.typecons;

import gl4d.gl,
       gl4d.math,
       gl4d.GLObject;

///
alias ArrayBuffer = Buffer!GL_ARRAY_BUFFER;
/// RefCounted version of ArrayBuffer.
alias ArrayBufferRef = BufferRef!GL_ARRAY_BUFFER;
///
alias ArrayBufferAllocator = BufferAllocator!GL_ARRAY_BUFFER;
///
alias ArrayBufferOverwriter = BufferOverwriter!GL_ARRAY_BUFFER;

///
alias ElementArrayBuffer = Buffer!GL_ELEMENT_ARRAY_BUFFER;
/// RefCounted version of ElementArrayBuffer.
alias ElementArrayBufferRef = BufferRef!GL_ELEMENT_ARRAY_BUFFER;
///
alias ElementArrayBufferAllocator = BufferAllocator!GL_ELEMENT_ARRAY_BUFFER;
///
alias ElementArrayBufferOverwriter = BufferOverwriter!GL_ELEMENT_ARRAY_BUFFER;

///
alias UniformBuffer = Buffer!GL_UNIFORM_BUFFER;
/// RefCounted version of UniformBuffer.
alias UniformBufferRef = BufferRef!GL_UNIFORM_BUFFER;
///
alias UniformBufferAllocator = BufferAllocator!GL_UNIFORM_BUFFER;
///
alias UniformBufferOverwriter = BufferOverwriter!GL_UNIFORM_BUFFER;

/// RefCounted version of Buffer.
template BufferRef(GLenum target) {
  alias BufferRef = RefCounted!(Buffer!target);
}

/// A wrapper type for OpenGL buffer.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct Buffer(GLenum target_) {
  mixin GLObject!(
      (x, y) => gl.GenBuffers(x, y),
      (x)    => gl.BindBuffer(target_, x),
      (x)    => gl.DeleteTextures(1, x)
    );

 public:
  ///
  enum target = target_;

  /// Binds this buffer to be written by transform feedbacks.
  static if (target_ == GL_ARRAY_BUFFER)
  void BindForTransformFeedback(int index) {
    assert(!empty);
    gl.BindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, index.to!GLuint, id);
  }

  /// Binds this buffer to the uniform block.
  static if (target_ == GL_UNIFORM_BUFFER)
  void BindForUniformBlock(int index) {
    assert(!empty);
    gl.BindBufferBase(GL_UNIFORM_BUFFER, index.to!GLuint, id);
  }
}

/// An allocator for buffers.
struct BufferAllocator(GLenum target) {
 public:
  ///
  size_t size;
  ///
  const(void)* data;
  ///
  GLenum usage = GL_STATIC_DRAW;

  /// Allocates the buffer with parameters this has.
  ///
  /// Binds the buffer automatically.
  void Allocate(ref BufferRef!target buffer)
  in {
    assert(!buffer.empty);
    assert(size > 0);
  }
  do {
    buffer.Bind();
    gl.BufferData(target, size.to!GLsizeiptr, data, usage);
  }
}

/// An overwriter for buffers.
struct BufferOverwriter(GLenum target) {
 public:
  ///
  size_t offset;
  ///
  size_t size;
  ///
  const(void)* data;

  /// Overwrites the buffer with parameters this has.
  ///
  /// The buffer will be bound automatically.
  void Overwrite(ref BufferRef!target buffer)
  in {
    assert(!buffer.empty);

    assert(offset >= 0);
    assert(size > 0);
  }
  do {
    buffer.Bind();
    gl.BufferSubData(target, offset.to!GLintptr, size.to!GLsizeiptr, data);
  }
}

/// Takes the buffer's data pointer.
///
/// T must be a BufferRef type.
///
/// The buffer will be bound automatically.
///
/// Escaping its scope, the pointer will be disabled automatically.
/// Returns: a voldemorte type which can behave as same as PtrT*
auto MapToRead(PtrT = void, T)(ref T buf) {
  return buf.Map!(PtrT, T.target, GL_READ_ONLY);
}
/// ditto
auto MapToWrite(PtrT = void, T)(ref T buf) {
  return buf.Map!(PtrT, T.target, GL_WRITE_ONLY);
}
/// ditto
auto MapToReadWrite(PtrT = void, T)(ref T buf) {
  return buf.Map!(PtrT, T.target, GL_READ_WRITE);
}
private auto Map(PtrT, GLenum target, GLenum usage)(ref BufferRef!target buf) {
  assert(!buf.empty);

  buf.Bind();
  auto ptr = gl.MapBuffer(target, usage);

  struct Mapper {
   public:
    @disable this(this);

    ~this() {
      gl.UnmapBuffer(target);
    }

    static if (usage == GL_READ_ONLY) {
      @property const(PtrT*) entity() const return { return cast(PtrT*) ptr; }
    } else {
      @property inout(PtrT*) entity() inout return { return cast(PtrT*) ptr; }
    }
    alias entity this;
  }
  return Mapper();
}
