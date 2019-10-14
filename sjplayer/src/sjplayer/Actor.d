/// License: MIT
module sjplayer.Actor;

import gl4d;

///
class Actor {
 public:
  ///
  this(ActorProgram program) {
    pos   = vec2(0, 0);
    speed = vec2(0, 0);
    color = vec4(0, 0, 0, 0);

    clip_lefttop     = vec2(0, 0);
    clip_rightbottom = vec2(0, 0);

    program_ = program;
  }

  ///
  void Draw() {
    program_.Draw(pos, speed, color);
  }

  ///
  vec2 pos;
  ///
  vec2 speed;
  ///
  vec4 color;

  ///
  vec2 clip_lefttop;
  ///
  vec2 clip_rightbottom;

 private:
  ActorProgram program_;
}

///
class ActorProgram {
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
    layout(location = 0) uniform vec2 pos;
    layout(location = 1) uniform vec2 speed;
    layout(location = 2) uniform vec4 color;

    in vec2  uv_;

    out vec4 pixel_;

    float line(float u, float p, float s) {
      return
        (1-smoothstep(0, 0.003, abs(u-p)));
    }

    void main() {
      float alpha =
        line(uv_.x, pos.x, speed.x) +
        line(uv_.y, pos.y, speed.y);
      pixel_    = color;
      pixel_.a *= clamp(alpha, 0, 1);
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
    with (VertexArrayAttacher()) {
      index     = 0;
      type      = GL_FLOAT;
      dimension = 2;
      Attach(vao_, verts_);
    }

    verts_.Bind();
    with (ArrayBufferAllocator()) {
      const v = [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1),];
      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }
  }

  ///
  void Draw(vec2 pos, vec2 speed, vec4 color) {
    program_.Use();
    program_.uniform!0 = pos;
    program_.uniform!1 = speed;
    program_.uniform!2 = color;

    vao_.Bind();
    gl.DrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }

 private:
  ProgramRef program_;

  ArrayBufferRef verts_;

  VertexArrayRef vao_;
}
