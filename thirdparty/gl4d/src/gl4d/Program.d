/// License: MIT
module gl4d.Program;

import std.algorithm,
       std.array,
       std.conv,
       std.exception,
       std.string,
       std.typecons;

import gl4d.gl,
       gl4d.math,
       gl4d.Shader;

/// Whether geometry shaders are available.
enum IsGeometryShaderAvailable = (glSupport >= GLSupport.gl40);

/// RefCounted version of OpenGL program.
alias ProgramRef = RefCounted!Program;

/// A wrapper type for OpenGL program.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct Program {
 public:
  @disable this(this);

  ///
  this(GLuint id) {
    this.id = id;

    assert(!empty);
    (Get!GL_LINK_STATUS == GL_TRUE).enforce(log);
  }
  ~this() {
    if (!empty) gl.DeleteProgram(id);
  }

  /// Makes this program current.
  void Use() {
    assert(!empty);
    gl.UseProgram(id);
  }
  /// Makes this program incurrent.
  void Unuse() {
    assert(!empty);
    gl.UseProgram(0);
  }

  /// Validates this program.
  ///
  /// If it's failed, throws an exception with log.
  void Validate() const {
    gl.ValidateProgram(id);
    (Get!GL_VALIDATE_STATUS == GL_TRUE).enforce(log);
  }

  /// This may takes too long time.
  @property string log() const {
    assert(!empty);

    const len = Get!GL_INFO_LOG_LENGTH;

    auto msg = new char[len];
    gl.GetProgramInfoLog(id, len, null, msg.ptr);
    return msg.to!string;
  }

  ///
  @property bool empty() const {
    return id == 0;
  }

  ///
  const GLuint id;

 private:
  // Be carefully, this may take too long time.
  GLint Get(GLenum param)() const {
    GLint temp = void;
    gl.GetProgramiv(id, param, &temp);
    return temp;
  }

  VertexShaderRef vertex_;

  static if (IsGeometryShaderAvailable)
    GeometryShaderRef geometry_;

  FragmentShaderRef fragment_;
}

/// A linker for OpenGL program.
struct ProgramLinker {
 public:
  ///
  VertexShaderRef vertex;

  static if (IsGeometryShaderAvailable) {
    ///
    GeometryShaderRef geometry;
    ///
    int geometryOutputVertices = 1024;
    ///
    GLenum geometryInputType = GL_POINTS;
    ///
    GLenum geometryOutputType = GL_POINTS;
  }

  ///
  FragmentShaderRef fragment;

  ///
  string[] feedbackVaryings;
  ///
  bool feedbackInterleaved;

  /// Creates new program with parameters this has.
  ProgramRef Link()
  in {
    assert(!vertex.empty);
    assert(!fragment.empty);
  }
  do {
    const id = gl.CreateProgram();

    gl.AttachShader(id, vertex.id);
    scope(exit) vertex = vertex.init;

    gl.AttachShader(id, fragment.id);
    scope(exit) fragment = fragment.init;

    static if (IsGeometryShaderAvailable) if (!geometry.empty) {
      gl.AttachShader(id, geometry.id);
      scope(exit) geometry = geometry.init;

      static if (glSupport >= GLSupport.gl40) {
        gl.ProgramParameteri(id, GL_GEOMETRY_VERTICES_OUT, geometryOutputVertices);

        gl.ProgramParameteri(id, GL_GEOMETRY_INPUT_TYPE,  geometryInputType);
        gl.ProgramParameteri(id, GL_GEOMETRY_OUTPUT_TYPE, geometryOutputType);
      }
    }

    if (feedbackVaryings.length > 0) {
      const varys = feedbackVaryings.map!toStringz.array;
      gl.TransformFeedbackVaryings(id,
          feedbackVaryings.length.to!GLsizei, cast(char**) varys.ptr,
          feedbackInterleaved? GL_INTERLEAVED_ATTRIBS: GL_SEPARATE_ATTRIBS);
    }

    gl.LinkProgram(id);
    return ProgramRef(id);
  }
}

/// Resets uniform values with the data. (The program must be current.)
///
/// The program must be current.
@property void uniform(int loc, T)(ref ProgramRef program, T data) {
  assert(!program.empty);

  static if (is(T == int)) {
    gl.Uniform1i(loc, data);
  } else static if (is(T == vec2i)) {
    gl.Uniform2i(loc, data.x, data.y);
  } else static if (is(T == vec3i)) {
    gl.Uniform3i(loc, data.x, data.y, data.z);
  } else static if (is(T == vec4i)) {
    gl.Uniform4i(loc, data.x, data.y, data.z, data.w);
  } else static if (is(T == float)) {
    gl.Uniform1f(loc, data);
  } else static if (is(T == vec2)) {
    gl.Uniform2f(loc, data.x, data.y);
  } else static if (is(T == vec3)) {
    gl.Uniform3f(loc, data.x, data.y, data.z);
  } else static if (is(T == vec4)) {
    gl.Uniform4f(loc, data.x, data.y, data.z, data.w);
  } else static if (is(T == mat2)) {
    gl.UniformMatrix2fv(loc, 1, true, &data[0][0]);
  } else static if (is(T == mat3)) {
    gl.UniformMatrix3fv(loc, 1, true, &data[0][0]);
  } else static if (is(T == mat4)) {
    gl.UniformMatrix4fv(loc, 1, true, &data[0][0]);
  } else {
    static assert(false);
  }
}
// Tests for the above template.
static assert(is(typeof((ref ProgramRef program) => program.uniform!0 = 0)));
static assert(is(typeof((ref ProgramRef program) => program.uniform!1 = vec4())));
static assert(is(typeof((ref ProgramRef program) => program.uniform!2 = mat4())));

/// Numbers uniform blocks of the names.
void NumberUniformBlocks(string[int] names)(ref ProgramRef program) {
  assert(!program.empty);

  GLuint ubi = void;
  static foreach (i, name; names) {
    ubi = gl.GetUniformBlockIndex(program.id, name.toStringz);
    gl.UniformBlockBinding(program.id, ubi, i.to!GLuint);
  }
}
