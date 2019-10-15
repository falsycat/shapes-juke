/// License: MIT
module sjplayer.CircleElement;

import std.algorithm,
       std.math;

import gl4d;

import sjplayer.ElementDrawer,
       sjplayer.ElementInterface,
       sjplayer.util.linalg;

///
class CircleElement : ElementInterface {
 public:
  ///
  static struct Instance {
    ///
    align(1) mat3 matrix = mat3.identity;
    ///
    align(1) float weight = 1;
    ///
    align(1) float smooth = 0.001;
    ///
    align(1) vec4 color = vec4(0, 0, 0, 0);
  }

  ///
  void Initialize() {
    alive        = false;
    damage       = 0;
    nearness_coe = 0;
    instance     = instance.init;
  }

  override DamageCalculationResult CalculateDamage(vec2 p1, vec2 p2) const {
    if (!alive) return DamageCalculationResult(0, 0);

    const m = matrix.inverse;
    const a = (m * vec3(p1, 1)).xy;
    const b = (m * vec3(p2, 1)).xy;
    const d = CalculateDistanceOriginAndLineSegment(a, b);

    if (d <= 1) {
      return DamageCalculationResult(damage, 0);
    }
    return DamageCalculationResult(0, 1 - (d-1).clamp(0, 1));
  }

  ///
  bool alive;
  ///
  float damage;
  ///
  float nearness_coe;
  ///
  Instance instance;
  alias instance this;
}

///
alias CircleElementDrawer = ElementDrawer!(
    CircleElementProgram,
    CircleElement,
    [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1)]);

///
class CircleElementProgram {
 public:
  ///
  enum ShaderHeader = "#version 330 core
#extension GL_ARB_explicit_uniform_location : enable";

  ///
  enum VertexShaderSrc = ShaderHeader ~ q{
    layout(location = 0) in vec2 vert;

    layout(location = 1) in vec3 m1;
    layout(location = 2) in vec3 m2;
    layout(location = 3) in vec3 m3;
    layout(location = 4) in float weight;
    layout(location = 5) in float smoooth;  // expected wrong spell
    layout(location = 6) in vec4  color;

    out vec2  uv_;
    out float weight_;
    out float smooth_;
    out vec4  color_;

    void main() {
      mat3 m   = transpose(mat3(m1, m2, m3));
      vec2 pos = (m * vec3(vert, 1)).xy;

      uv_     = vert;
      weight_ = weight;
      smooth_ = smoooth;
      color_  = color;
      gl_Position = vec4(pos, 0, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    in vec2  uv_;
    in float weight_;
    in float smooth_;
    in vec4  color_;

    out vec4 pixel_;

    float circle() {
      float r = length(uv_);
      float w = 1 - weight_;
      return
        smoothstep(w-smooth_, w, r) *
        (1 - smoothstep(1-smooth_, 1, r));
    }

    void main() {
      pixel_    = color_;
      pixel_.a *= circle();
    }
  };

  ///
  this() {
    ProgramLinker linker;
    linker.vertex   = VertexShader.Compile(VertexShaderSrc);
    linker.fragment = FragmentShader.Compile(FragmentShaderSrc);
    program_ = linker.Link();
    program_.Validate();
  }

  ///
  void SetupVertexArray(ref VertexArrayRef vao,
      ref ArrayBufferRef verts, ref ArrayBufferRef instances) {
    with (VertexArrayAttacher()) {
      // verts
      type      = GL_FLOAT;
      dimension = 2;
      Attach(vao, verts);
      ++index;

      type    = GL_FLOAT;
      divisor = 1;
      stride  = CircleElement.Instance.sizeof;
      offset  = 0;

      // matrix
      dimension = 3;
      Attach(vao, instances);
      offset += float.sizeof*3;
      ++index;
      Attach(vao, instances);
      offset += float.sizeof*3;
      ++index;
      Attach(vao, instances);
      offset += float.sizeof*3;
      ++index;

      // weight
      dimension = 1;
      Attach(vao, instances);
      offset += float.sizeof*1;
      ++index;

      // smooth
      dimension = 1;
      Attach(vao, instances);
      offset += float.sizeof*1;
      ++index;

      // color
      dimension = 4;
      Attach(vao, instances);
      offset += float.sizeof*4;
      ++index;
    }
  }

  ///
  void Use() {
    program_.Use();
  }

 private:
  ProgramRef program_;
}
