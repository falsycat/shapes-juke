/// License: MIT
module sjplayer.SquareElement;

import gl4d;

import sjplayer.ElementDrawer,
       sjplayer.ElementInterface;

///
class SquareElement : ElementInterface {
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
    return DamageCalculationResult(0, 0);  // TODO:
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
alias SquareElementDrawer = ElementDrawer!(
    SquareElementProgram,
    SquareElement,
    [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1)]);

///
class SquareElementProgram {
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

    float square() {
      float w = 1-weight_;
      float s = smooth_;
      return clamp(
          smoothstep(w-s, w, abs(uv_.x)) +
          smoothstep(w-s, w, abs(uv_.y)), 0, 1);
    }

    void main() {
      pixel_    = color_;
      pixel_.a *= square();
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
      stride  = SquareElement.Instance.sizeof;
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
