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

    out vec3 vert_;
    out vec2 uv_;

    void main() {
      vert_ = vert;
      uv_   = uv;
      gl_Position = P * V * M * vec4(vert, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(location = 3) uniform sampler2D tex;
    layout(location = 4) uniform vec4      color;
    layout(location = 5) uniform int       frame;
    layout(location = 6) uniform float     model_width;

    in vec3 vert_;
    in vec2 uv_;

    out vec4 pixel_;

    float choose(int a, int b, float a_big, float b_big) {
      float condition = step(float(a), float(b));
      return condition * b_big + (1-condition) * a_big;
    }
    float choose(float a, float b, float c, float hit, float other) {
      float condition = step(a, b) * step(b, c);
      return condition * hit + (1-condition) * other;
    }

    void main() {
      float vx = vert_.x / model_width;
      vec2  uv = uv_;

      uv.y = choose(3, frame%4, uv.y,
          choose(0, vx, 0.25, clamp(uv.y, 0, 0.4), uv.y));
      uv.y = choose(15, frame%18, uv.y,
          choose(0.1, vx, 0.2, clamp(uv.y, 0.6, 1), uv.y));
      uv.y = choose(8, frame%14, uv.y,
          choose(0.1, vx, 0.6, clamp(uv.y, 0, 0.8), uv.y));
      uv.y = choose(21, frame%29, uv.y,
          choose(0.2, vx, 0.3, clamp(uv.y, 0.3, 1), uv.y));
      uv.y = choose(20, frame%23, uv.y,
          choose(0.4, vx, 0.6, clamp(uv.y, 0.4, 1), uv.y));
      uv.y = choose(5, frame%6, uv.y,
          choose(0.5, vx, 0.8, clamp(uv.y, 0, 0.7), uv.y));
      uv.y = choose(15, frame%17, uv.y,
          choose(0.6, vx, 0.7, clamp(uv.y, 0.5, 1), uv.y));
      uv.y = choose(7, frame%9, uv.y,
          choose(0.6, vx, 0.9, clamp(uv.y, 0.3, 1), uv.y));

      pixel_    = color;
      pixel_.a *= texture(tex, uv).r;
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
  void Use(mat4 proj, mat4 view, mat4 model,
      ref Texture2DRef tex, vec4 color, int frame, float model_width) {
    tex.BindToUnit(GL_TEXTURE0);
    sampler_.Bind(0);

    program_.Use();
    program_.uniform!0 = proj;
    program_.uniform!1 = view;
    program_.uniform!2 = model;
    program_.uniform!3 = 0;
    program_.uniform!4 = color;
    program_.uniform!5 = frame;
    program_.uniform!6 = model_width;
  }

 private:
  ProgramRef program_;

  SamplerRef sampler_;
}
