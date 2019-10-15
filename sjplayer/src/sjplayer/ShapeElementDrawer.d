/// License: MIT
module sjplayer.ShapeElementDrawer;

import std.algorithm,
       std.conv,
       std.exception;

import gl4d;

import sjplayer.AbstractShapeElement,
       sjplayer.ElementDrawerInterface,
       sjplayer.ShapeElementProgram;

///
class ShapeElementDrawer(Program, vec2[] vertices) : ElementDrawerInterface {
 public:
  ///
  enum MaxInstanceCount = 512;

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
    with (ArrayBufferAllocator()) {
      size  = ShapeElementProgramInstance.sizeof * MaxInstanceCount;
      usage = GL_DYNAMIC_DRAW;
      Allocate(instances_);
    }
  }

  override void Draw() {
    size_t alive_count;

    instances_.Bind();
    {
      auto ptr = instances_.MapToWrite!ShapeElementProgramInstance();
      foreach (const shape; shapes_.filter!"a.alive") {
        enforce(alive_count <= MaxInstanceCount);
        ptr[alive_count++] = shape.instance;
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

  const AbstractShapeElement[] shapes_;

  ArrayBufferRef verts_;
  ArrayBufferRef instances_;
  VertexArrayRef vao_;
}
