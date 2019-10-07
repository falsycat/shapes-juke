/// License: MIT
module sjplayer.Background;

import gl4d;

///
class Background {
 public:
  ///
  this(BackgroundProgram program) {
    program_ = program;
  }

  ///
  void Initialize() {
    inner_color = vec4(0, 0, 0, 0);
    outer_color = vec4(0, 0, 0, 0);
  }
  ///
  void Draw() {
    program_.Draw(inner_color, outer_color);
  }

  ///
  vec4 inner_color;
  ///
  vec4 outer_color;

 private:
  BackgroundProgram program_;
}

///
class BackgroundProgram {
 public:
  ///
  enum ShaderHeader = "#version 330 core
#extension GL_ARB_explicit_uniform_location : enable";

  ///
  enum VertexShaderSrc = ShaderHeader ~ q{
    layout(location = 0) in vec2 vert;

    out vec2 uv_;

    void main() {
      uv_         = vert;
      gl_Position = vec4(vert, 0, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(location = 0) uniform vec4 inner_color;
    layout(location = 1) uniform vec4 outer_color;

    in vec2  uv_;

    out vec4 pixel_;

    void main() {
      pixel_ = (outer_color - inner_color)*length(uv_)/sqrt(2) + inner_color;
    }
  };

  ///
  this() {
    ProgramLinker linker;
    linker.vertex   = VertexShader.Compile(VertexShaderSrc);
    linker.fragment = FragmentShader.Compile(FragmentShaderSrc);
    program_ = linker.Link();
    program_.Validate();

    vao_   = VertexArray.Create();
    verts_ = ArrayBuffer.Create();

    vao_.Bind();
    VertexArrayAttacher attacher;
    with (attacher) {
      index     = 0;
      type      = GL_FLOAT;
      dimension = 2;
      Attach(vao_, verts_);
    }

    verts_.Bind();
    ArrayBufferAllocator verts_allocator;
    with (verts_allocator) {
      const v = [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1),];
      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }
  }

  ///
  void Draw(vec4 inner, vec4 outer) {
    program_.Use();
    program_.uniform!0 = inner;
    program_.uniform!1 = outer;

    vao_.Bind();
    gl.DrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }

 private:
  ProgramRef program_;

  ArrayBufferRef verts_;

  VertexArrayRef vao_;
}
