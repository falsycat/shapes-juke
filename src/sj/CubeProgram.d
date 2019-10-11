/// License: MIT
module sj.CubeProgram;

import std.conv,
       std.range.primitives;

import gl4d;

///
class CubeProgram {
 public:
  ///
  alias Instance = mat4;

  ///
  enum ShaderHeader = "#version 330 core
#extension GL_ARB_explicit_uniform_location : enable";

  ///
  enum VertexShaderSrc = ShaderHeader ~ q{
    layout(location = 0) in vec3 vert;
    layout(location = 1) in vec3 normal;

    layout(location = 2) in vec4 m1;
    layout(location = 3) in vec4 m2;
    layout(location = 4) in vec4 m3;
    layout(location = 5) in vec4 m4;

    out vec3 normal_;

    void main() {
      mat4 m = transpose(mat4(m1, m2, m3, m4));

      normal_     = (m * vec4(normal, 1)).xyz;
      gl_Position = m * vec4(vert, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(location = 0) uniform vec3 light_color;
    layout(location = 1) uniform vec3 light_direction;
    layout(location = 2) uniform vec3 ambient_color;

    in vec3 normal_;

    out vec4 pixel_;

    void main() {
      float light = dot(normalize(light_direction), normalize(normal_));
      vec3  color = clamp(light_color * light + ambient_color, 0, 1);

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
      size  = MaxInstanceCount * Instance.sizeof;
      usage = GL_DYNAMIC_DRAW;
      Allocate(instances_);
    }
  }

  ///
  void Draw(R)(R cubes, vec3 lcolor, vec3 light, vec3 acolor)
      if (isInputRange!R && is(ElementType!R == Instance)) {
    size_t length;
    {
      auto ptr = instances_.MapToWrite!Instance();
      foreach (const ref c; cubes) {
        assert(length < MaxInstanceCount);
        ptr[length++] = c;
      }
    }

    program_.Use();
    program_.uniform!0 = lcolor;
    program_.uniform!1 = light;
    program_.uniform!2 = acolor;

    vao_.Bind();
    gl.DrawArraysInstanced(GL_TRIANGLES, 0, 6*6, length.to!int);
  }

 private:
  ProgramRef program_;

  VertexArrayRef vao_;

  ArrayBufferRef verts_;

  ArrayBufferRef instances_;
}
