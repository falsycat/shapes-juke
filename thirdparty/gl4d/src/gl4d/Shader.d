/// License: MIT
module gl4d.Shader;

import std.conv,
       std.exception,
       std.string,
       std.typecons;

import gl4d.gl;

/// A wrapper type for OpenGL vertex shader.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct VertexShader {
  mixin Shader!GL_VERTEX_SHADER;
}
/// RefCounted version of VertexShader.
alias VertexShaderRef = RefCounted!VertexShader;

/// A wrapper type for OpenGL geometry shader.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct GeometryShader {
  mixin Shader!GL_GEOMETRY_SHADER;
}
/// RefCounted version of GeometryShader.
alias GeometryShaderRef = RefCounted!GeometryShader;

/// A wrapper type for OpenGL fragment shader.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct FragmentShader {
  mixin Shader!GL_FRAGMENT_SHADER;
}
/// RefCounted version of FragmentShader.
alias FragmentShaderRef = RefCounted!FragmentShader;

/// A body of shader structures which cannot be refered from other modules.
private mixin template Shader(GLenum type) {
 public:
  @disable this(this);

  /// Creates new shader from the source with the type.
  static RefCounted!This Compile(string src) {
    const id = gl.CreateShader(type);

    const srcptr = src.toStringz;
    gl.ShaderSource(id, 1, &srcptr, null);
    gl.CompileShader(id);

    return RefCounted!This(id);
  }

  ///
  this(GLuint id) {
    this.id = id;

    assert(!empty);
    (Get!GL_COMPILE_STATUS == GL_TRUE).enforce(log);
  }
  ~this() {
    if (!empty) gl.DeleteShader(id);
  }

  /// This may takes too long time.
  @property string log() const {
    assert(!empty);

    const len = Get!GL_INFO_LOG_LENGTH;
    if (len == 0) return null;

    auto msg = new char[len];
    gl.GetShaderInfoLog(id, len, null, msg.ptr);
    return msg.to!string;
  }

  ///
  @property bool empty() const {
    return id == 0;
  }

  ///
  const GLuint id;

 private:
  alias This = typeof(this);

  // Be carefully, this may take too long time.
  GLint Get(GLenum param)() const {
    assert(!empty);

    GLint temp = void;
    gl.GetShaderiv(id, param, &temp);
    return temp;
  }
}
