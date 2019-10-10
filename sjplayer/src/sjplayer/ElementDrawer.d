/// License: MIT
module sjplayer.ElementDrawer;

import std.algorithm,
       std.conv;

import gl4d;

import sjplayer.ElementDrawerInterface;

///
class ElementDrawer(Program, Element, vec2[] vertices) :
  ElementDrawerInterface {
 public:
  ///
  alias Instance = typeof(Element.instance);

  ///
  this(Program program, in Element[] elements)
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
      const v = vertices;  // place to memory

      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }

    instances_.Bind();
    ArrayBufferAllocator instance_allocator;
    with (instance_allocator) {
      size  = Instance.sizeof * elements.length;
      usage = GL_DYNAMIC_DRAW;
      Allocate(instances_);
    }
  }

  override void Draw() {
    size_t alive_count;

    instances_.Bind();
    {
      auto ptr = instances_.MapToWrite!Instance();
      foreach (const element; elements_.filter!"a.alive") {
        ptr[alive_count++] = element.instance;
      }
    }

    program_.Use();
    vao_.Bind();

    if (alive_count == 0) return;
    gl.DrawArraysInstanced(
        GL_TRIANGLE_FAN, 0, vertices.length.to!int, alive_count.to!int);
  }

 private:
  Program program_;

  const Element[] elements_;

  ArrayBufferRef verts_;
  ArrayBufferRef instances_;
  VertexArrayRef vao_;
}
