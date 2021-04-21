/// License: MIT
module gl4d.GLObject;

import gl4d.gl;

/// A template for OpenGL objects' wrapper types.
mixin template GLObject(alias generator, alias binder, alias deleter) {
  import std.algorithm,
         std.array,
         std.typecons;

 public:
  @disable this(this);

  /// Creates a single object.
  static RefCounted!This Create() {
    GLuint id;
    generator(1, &id);
    return RefCounted!This(id);
  }
  /// Creates multiple objects.
  static RefCounted!This[] Create(int count) {
    assert(count > 0);
    auto id = new GLuint[count];
    generator(count, id.ptr);
    return id.map!(i => RefCounted!This(i)).array;
  }

  ~this() {
    if (!empty) deleter(&id);
  }

  static if (is(typeof(() => binder(0)))) {
    /// Binds this object.
    void Bind() {
      assert(!empty);
      binder(id);
    }
    /// Unbinds this object
    void Unbind() {
      assert(!empty);
      binder(0);
    }
  }

  ///
  @property bool empty() const {
    return id == 0;
  }

  ///
  const GLuint id;

 private:
  alias This = typeof(this);
}
