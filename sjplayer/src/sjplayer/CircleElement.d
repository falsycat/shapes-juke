/// License: MIT
module sjplayer.CircleElement;

import std.algorithm,
       std.conv,
       std.exception;

import gl4d;

import sjplayer.ElementInterface;

///
class CircleElement : ElementInterface {
 public:
  ///
  static struct Instance {
    /// this should be transposed
    align(1) mat3 matrix = mat3.identity;
    ///
    align(1) float weight = 1;
    ///
    align(1) float smooth = 0;
    ///
    align(1) vec4 color = vec4(0, 0, 0, 0);
  }

  override void Initialize() {
    alive        = false;
    damage       = 0;
    nearness_coe = 0;
    instance     = instance.init;
  }

  override DamageCalculationResult CalculateDamage(vec2 p1, vec2 p2) const {
    // TODO:
    return DamageCalculationResult(0, 0);
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
class CircleElementDrawer : ElementDrawerInterface {
 public:
  ///
  this(CircleElementProgram program, in CircleElement[] elements)
      in (program)
      in (elements.length > 0) {
    program_  = program;
    elements_ = elements;

    vao_       = VertexArray.Create();
    verts_     = ArrayBuffer.Create();
    instances_ = ArrayBuffer.Create();

    vao_.Bind();
    program_.SetupVertexArray(vao_, verts_, instances_);

    verts_.Bind();
    ArrayBufferAllocator verts_allocator;
    with (verts_allocator) {
      const v = [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1),];
      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }

    instances_.Bind();
    ArrayBufferAllocator instance_allocator;
    with (instance_allocator) {
      size  = CircleElement.Instance.sizeof * elements.length;
      usage = GL_DYNAMIC_DRAW;
      Allocate(instances_);
    }
  }

  override void Draw() {
    size_t alive_count;

    instances_.Bind();
    ArrayBufferOverwriter instance_writer;
    foreach (const element; elements_.filter!"a.alive") with (instance_writer) {
      data   = &element.instance;
      offset = alive_count++ * CircleElement.Instance.sizeof;
      size   = CircleElement.Instance.sizeof;
      Overwrite(instances_);
    }

    program_.Use();
    vao_.Bind();

    if (alive_count == 0) return;
    gl.DrawArraysInstanced(GL_TRIANGLE_FAN, 0, 4, alive_count.to!int);
  }

 private:
  CircleElementProgram program_;

  const CircleElement[] elements_;

  ArrayBufferRef verts_;
  ArrayBufferRef instances_;
  VertexArrayRef vao_;
}

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
      mat3 m   = mat3(m1, m2, m3);
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
    VertexArrayAttacher attacher;
    with (attacher) {
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
