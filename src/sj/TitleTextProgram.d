/// License: MIT
module sj.TitleTextProgram;

import gl4d;

import sj.util.image;

///
class TitleTextProgram {
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
      uv_ = uv;
      gl_Position = P * V * M * vec4(vert, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(location = 3) uniform sampler2D tex;
    layout(location = 4) uniform int frame;

    in vec2 uv_;

    out vec4 pixel_;

    float stepstep(float a, float b, float x) {
      return step(a, x) * (1-step(b, x));
    }

    void main() {
      vec2 uv = uv_;

      uv.x += stepstep(0.1, 0.2, uv.y) *
        step(51.0, float(frame%61)) * 0.03;
      uv.x += stepstep(0.3, 0.35, uv.y) *
        step(85.0, float(frame%103)) * -0.05;
      uv.x += stepstep(0.3, 0.4, uv.y) *
        step(294.0, float(frame%303)) * 0.07;
      uv.x += stepstep(0.35, 0.45, uv.y) *
        step(475.0, float(frame%829)) * -0.01;
      uv.x += stepstep(0.5, 0.6, uv.y) *
        step(22.0, float(frame%78)) * 0.002;
      uv.x += stepstep(0.55, 0.65, uv.y) *
        step(32.0, float(frame%37)) * -0.007;
      uv.x += stepstep(0.85, 0.95, uv.y) *
        step(82.0, float(frame%273)) * 0.004;
      uv.x += stepstep(0.7, 0.9, uv.y) *
        step(152.0, float(frame%203)) * -0.005;

      vec4 texel = texture(tex, clamp(uv, 0, 1));
      pixel_.r = texel.a;
      pixel_.g = texel.b;
      pixel_.b = texel.g;
      pixel_.a = texel.r;

      pixel_.r += stepstep(0.2, 0.25, uv.y) *
        step(20.0, float(frame%30)) * 0.2;
      pixel_.r += stepstep(0.5, 0.55, uv.y) *
        step(83.0, float(frame%127)) * 0.2;
      pixel_.r += stepstep(0.6, 0.75, uv.y) *
        step(18, float(frame%21)) * 0.2;
    }
  };

  ///
  enum ImgBuf = cast(ubyte[]) import("images/title.png");

  ///
  this() {
    ProgramLinker linker;
    linker.vertex   = VertexShader.Compile(VertexShaderSrc);
    linker.fragment = FragmentShader.Compile(FragmentShaderSrc);
    program_ = linker.Link();
    program_.Validate();

    tex_     = CreateTextureFromBuffer(ImgBuf);
    sampler_ = Sampler.Create();

    SamplerConfigurer configurer;
    with (configurer) {
      filterMin = GL_LINEAR;
      filterMag = GL_LINEAR;
      Configure(sampler_);
    }

    vao_      = VertexArray.Create();
    vertices_ = ArrayBuffer.Create();

    vao_.Bind();
    VertexArrayAttacher attacher;
    with (attacher) {
      index     = 0;
      type      = GL_FLOAT;
      offset    = 0;
      stride    = Vertex.sizeof;
      dimension = 3;
      Attach(vao_, vertices_);

      index     = 1;
      type      = GL_FLOAT;
      offset    = vec3.sizeof;
      stride    = Vertex.sizeof;
      dimension = 2;
      Attach(vao_, vertices_);
    }

    vertices_.Bind();
    ArrayBufferAllocator allocator;
    with (allocator) {
      const v = [
        -1f,  1f, 0f,  1f, 0f,
        -1f, -1f, 0f,  1f, 1f,
         1f, -1f, 0f,  0f, 1f,
         1f,  1f, 0f,  0f, 0f,
      ];
      data  = v.ptr;
      size  = v.length * v[0].sizeof;
      usage = GL_STATIC_DRAW;
      Allocate(vertices_);
    }
  }

  ///
  void Draw(mat4 proj, mat4 view, mat4 model, int frame) {
    tex_.BindToUnit(GL_TEXTURE0);
    sampler_.Bind(0);

    program_.Use();
    program_.uniform!0 = proj;
    program_.uniform!1 = view;
    program_.uniform!2 = model;
    program_.uniform!3 = 0;
    program_.uniform!4 = frame;

    vao_.Bind();
    gl.DrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }

 private:
  ProgramRef program_;

  Texture2DRef tex_;

  SamplerRef sampler_;

  VertexArrayRef vao_;

  ArrayBufferRef vertices_;
}
