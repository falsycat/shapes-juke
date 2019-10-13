/// License: MIT
module sj.TextProgram;

import gl4d;

///
class TextProgram {
 public:
  ///
  static struct Vertex {
   public:
    ///
    align(1) vec3 pos;
    ///
    align(1) vec2 uv;
  }

  ///
  enum ShaderHeader = "#version 330 core
#extension GL_ARB_explicit_uniform_location : enable";

  ///
  enum VertexShaderSrc = ShaderHeader ~ q{
    layout(location = 0) uniform mat4 P;
    layout(location = 1) uniform mat4 V;
    layout(location = 2) uniform mat4 M;

    layout(location = 0) in vec3 vert;
    layout(location = 1) in vec2 uv;

    out vec2 uv_;

    void main() {
      uv_   = uv;
      gl_Position = P * V * M * vec4(vert, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(location = 3) uniform sampler2D tex;
    layout(location = 4) uniform vec4      color;

    in vec2 uv_;

    out vec4 pixel_;

    void main() {
      pixel_    = color;
      pixel_.a *= texture(tex, uv_).r;
    }
  };

  ///
  this() {
    ProgramLinker linker;
    linker.vertex   = VertexShader.Compile(VertexShaderSrc);
    linker.fragment = FragmentShader.Compile(FragmentShaderSrc);
    program_ = linker.Link();
    program_.Validate();

    sampler_ = Sampler.Create();
    SamplerConfigurer configurer;
    with (configurer) {
      filterMin = GL_LINEAR;
      filterMag = GL_LINEAR;
      Configure(sampler_);
    }
  }

  ///
  void SetupVertexArray(ref VertexArrayRef vao, ref ArrayBufferRef vertices) {
    vao.Bind();
    VertexArrayAttacher attacher;
    with (attacher) {
      index     = 0;
      type      = GL_FLOAT;
      offset    = 0;
      stride    = Vertex.sizeof;
      dimension = 3;
      Attach(vao, vertices);

      index     = 1;
      type      = GL_FLOAT;
      offset    = vec3.sizeof;
      stride    = Vertex.sizeof;
      dimension = 2;
      Attach(vao, vertices);
    }
  }

  ///
  void Use(mat4 proj, mat4 view, mat4 model, ref Texture2DRef tex, vec4 color) {
    tex.BindToUnit(GL_TEXTURE0);
    sampler_.Bind(0);

    program_.Use();
    program_.uniform!0 = proj;
    program_.uniform!1 = view;
    program_.uniform!2 = model;
    program_.uniform!3 = 0;
    program_.uniform!4 = color;
  }

 private:
  ProgramRef program_;

  SamplerRef sampler_;
}
