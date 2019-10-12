/// License: MIT
module sj.CubeProgram;

import std.conv,
       std.range.primitives,
       std.string;

import gl4d;

///
class CubeProgram {
 public:
  ///
  static struct Material {
   public:
    ///
    vec3 diffuse_color = vec3(1, 1, 1);
    private float padding0_;

    ///
    vec3 specular_color = vec3(1, 1, 1);
    private float padding1_;

    ///
    vec3 light_color = vec3(1, 1, 1);
    private float padding2_;
    ///
    vec3 light_power = vec3(20, 20, 20);
    private float padding3_;

    ///
    vec3 ambient_color = vec3(0.3, 0.3, 0.3);
    private float padding4_;
  }

  ///
  enum ShaderHeader = "#version 330 core
#extension GL_ARB_explicit_uniform_location : enable";

  ///
  enum VertexShaderSrc = ShaderHeader ~ q{
    layout(location = 0) uniform mat4 P;
    layout(location = 1) uniform mat4 V;
    layout(location = 2) uniform vec3 lightpos;

    layout(location = 0) in vec3 vert;
    layout(location = 1) in vec3 normal;

    layout(location = 2) in vec4 m1;
    layout(location = 3) in vec4 m2;
    layout(location = 4) in vec4 m3;
    layout(location = 5) in vec4 m4;

    out vec3  lightdir_;
    out vec3  normal_;
    out vec3  eyedir_;
    out float distance_;

    void main() {
      mat4 M = transpose(mat4(m1, m2, m3, m4));

      vec3 lightpos_camera = (V * vec4(lightpos, 1)).xyz;
      vec3 vert_camera     = (V * M * vec4(vert, 1)).xyz;
      vec3 normal_camera   = (V * M * vec4(normal, 0)).xyz;

      eyedir_     = vec3(0, 0, 0) - vert_camera;
      normal_     = normal_camera;
      lightdir_   = lightpos_camera + eyedir_;
      distance_   = length(lightpos_camera - vert_camera);

      gl_Position = P * V * M * vec4(vert, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(std140) uniform Material {
      vec3 diffuse_color;

      vec3 specular_color;

      vec3 light_color;
      vec3 light_power;

      vec3 ambient_color;
    } material;

    in vec3  lightdir_;
    in vec3  normal_;
    in vec3  eyedir_;
    in float distance_;

    out vec4 pixel_;

    void main() {
      vec3 l = normalize(lightdir_);
      vec3 n = normalize(normal_);

      vec3 e = normalize(eyedir_);
      vec3 r = reflect(-l, n);

      float diffuse_cos = clamp(dot(l, n), 0, 1);
      float reflect_cos = clamp(dot(e, r), 0, 1);

      vec3 color_without_ambient =
        material.diffuse_color  * diffuse_cos +
        material.specular_color * pow(reflect_cos, 5);

      vec3 color =
        material.ambient_color +
        color_without_ambient * material.light_color * material.light_power / pow(distance_, 2);
      pixel_ = vec4(color, 1);
    }
  };

  ///
  enum MaxInstanceCount = 10;

  ///
  this() {
    ProgramLinker linker;
    linker.vertex   = VertexShader.Compile(VertexShaderSrc);
    linker.fragment = FragmentShader.Compile(FragmentShaderSrc);
    program_ = linker.Link();
    program_.Validate();

    material_       = UniformBuffer.Create();
    material_index_ = gl.GetUniformBlockIndex(program_.id, "Material".toStringz);

    material_.Bind();
    UniformBufferAllocator material_allocator;
    with (material_allocator) {
      data  = null;
      size  = Material.sizeof;
      usage = GL_DYNAMIC_DRAW;
      Allocate(material_);
    }

    vao_       = VertexArray.Create();
    verts_     = ArrayBuffer.Create();
    instances_ = ArrayBuffer.Create();

    vao_.Bind();
    VertexArrayAttacher attacher;
    with (attacher) {
      index     = 0;
      type      = GL_FLOAT;
      offset    = vec3.sizeof * 0;
      stride    = vec3.sizeof * 2;
      dimension = 3;
      Attach(vao_, verts_);

      index     = 1;
      type      = GL_FLOAT;
      offset    = vec3.sizeof * 1;
      stride    = vec3.sizeof * 2;
      dimension = 3;
      Attach(vao_, verts_);

      index     = 2;
      type      = GL_FLOAT;
      offset    = vec4.sizeof * 0;
      stride    = vec4.sizeof * 4;
      dimension = 4;
      divisor   = 1;
      Attach(vao_, instances_);
      index   = 3;
      offset += vec4.sizeof;
      Attach(vao_, instances_);
      index   = 4;
      offset += vec4.sizeof;
      Attach(vao_, instances_);
      index   = 5;
      offset += vec4.sizeof;
      Attach(vao_, instances_);
    }

    verts_.Bind();
    ArrayBufferAllocator verts_allocator;
    with (verts_allocator) {
      enum v = [
        // left
        vec3(-1, 1, -1), vec3(-1,  1,  1), vec3(-1, -1, 1),
        vec3(-1, 1, -1), vec3(-1, -1, -1), vec3(-1, -1, 1),

        // right
        vec3(1, 1, -1), vec3(1,  1,  1), vec3(1, -1, 1),
        vec3(1, 1, -1), vec3(1, -1, -1), vec3(1, -1, 1),

        // top
        vec3(-1, 1, -1), vec3(-1, 1,  1), vec3(1, 1, 1),
        vec3(-1, 1, -1), vec3( 1, 1, -1), vec3(1, 1, 1),

        // bottom
        vec3(-1, -1, -1), vec3(-1, -1,  1), vec3(1, -1, 1),
        vec3(-1, -1, -1), vec3( 1, -1, -1), vec3(1, -1, 1),

        // front
        vec3(-1, 1, -1), vec3( 1,  1, -1), vec3(1, -1, -1),
        vec3(-1, 1, -1), vec3(-1, -1, -1), vec3(1, -1, -1),

        // back
        vec3(-1, 1, 1), vec3( 1,  1, 1), vec3(1, -1, 1),
        vec3(-1, 1, 1), vec3(-1, -1, 1), vec3(1, -1, 1),
      ];
      enum n = [
        vec3(-1,  0,  0),  // left
        vec3( 1,  0,  0),  // right
        vec3( 0,  1,  0),  // top
        vec3( 0, -1,  0),  // bottom
        vec3( 0,  0, -1),  // front
        vec3( 0,  0,  1),  // back
      ];
      enum d = {
        vec3[] d;
        foreach (i, p; v) d ~= [p, n[i/6]];
        return d;
      }();

      const d_mem = d;
      data  = d_mem.ptr;
      size  = d_mem[0].sizeof * d_mem.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }

    instances_.Bind();
    ArrayBufferAllocator instances_allocator;
    with (instances_allocator) {
      data  = null;
      size  = MaxInstanceCount * mat4.sizeof;
      usage = GL_DYNAMIC_DRAW;
      Allocate(instances_);
    }
  }

  ///
  void Draw(R)(R cubes, mat4 projection, mat4 view, vec3 lightpos, Material material)
      if (isInputRange!R && is(ElementType!R == mat4)) {
    {
      auto ptr = material_.MapToWrite!Material();
      *ptr = material;
    }

    program_.Use();
    program_.uniform!0 = projection;
    program_.uniform!1 = view;
    program_.uniform!2 = lightpos;
    material_.BindForUniformBlock(material_index_);

    size_t length;
    {
      auto ptr = instances_.MapToWrite!mat4();
      foreach (const ref c; cubes) {
        assert(length < MaxInstanceCount);
        ptr[length++] = c;
      }
    }
    if (length == 0) return;

    vao_.Bind();
    gl.DrawArraysInstanced(GL_TRIANGLES, 0, 6*6, length.to!int);
  }

 private:
  ProgramRef program_;

  UniformBufferRef material_;

  VertexArrayRef vao_;

  ArrayBufferRef verts_;

  ArrayBufferRef instances_;

  const GLuint material_index_;
}
