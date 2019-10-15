/// License: MIT
module sjplayer.ShapeElementDrawer;

import std.algorithm,
       std.conv,
       std.exception;

import gl4d;

import sjplayer.AbstractShapeElement,
       sjplayer.ElementDrawerInterface,
       sjplayer.ScriptRuntimeException,
       sjplayer.ShapeElementProgram;

///
class ShapeElementDrawer(Program, vec2[] vertices) : ElementDrawerInterface {
 public:
  ///
  enum DefaultInstanceCount = 128;

  ///
  this(Program program, in AbstractShapeElement[] shapes)
      in (program)
      in (shapes.length > 0) {
    program_ = program;
    shapes_  = shapes;

    vao_       = VertexArray.Create();
    verts_     = ArrayBuffer.Create();
    instances_ = ArrayBuffer.Create();

    vao_.Bind();
    program_.SetupVertexArray(vao_, verts_, instances_);

    verts_.Bind();
    with (ArrayBufferAllocator()) {
      const v = vertices;  // place to memory

      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }

    instances_.Bind();
    AllocateInstanceBufferIfNeeded(DefaultInstanceCount);
  }

  override void Draw() {
    const alive_count = shapes_.filter!"a.alive".count!"true";
    instances_.Bind();
    AllocateInstanceBufferIfNeeded(alive_count);
    {
      auto data = instances_.MapToWrite!ShapeElementProgramInstance();
      auto ptr  = data.entity;
      foreach (const shape; shapes_.filter!"a.alive") {
        *ptr++ = shape.instance;
      }
    }

    program_.Use();
    vao_.Bind();

    if (alive_count == 0) return;
    gl.DrawArraysInstanced(
        GL_TRIANGLE_FAN, 0, vertices.length.to!int, alive_count.to!int);
  }

 private:
  void AllocateInstanceBufferIfNeeded(size_t count) {
    if (instances_count_ >= count) return;

    with (ArrayBufferAllocator()) {
      size  = ShapeElementProgramInstance.sizeof * count;
      usage = GL_DYNAMIC_DRAW;
      Allocate(instances_);
    }
    instances_count_ = count;
  }

  Program program_;

  const AbstractShapeElement[] shapes_;

  ArrayBufferRef verts_;
  ArrayBufferRef instances_;
  VertexArrayRef vao_;

  size_t instances_count_;
}
