#!/usr/bin/env dub

/+ dub.json:
{
  "name": "test",

  "dependencies": {
    "bindbc-sdl": "~>0.11.0",
    "gl4d": {"path": "."}
  },
  "versions": ["SDL_209"]
}
+/

import std;
import bindbc.sdl;
import gl4d;

enum ShaderHeader = "#version 330 core
#extension GL_ARB_explicit_uniform_location : enable";

enum VertexShaderSource = ShaderHeader~q{
  layout(location=0) in vec4 pos;

  layout(std140) uniform uniformblock {
    float value;
  } ub;

  out vec2  uv;
  out float feedback_value;

  void main() {
    uv             = pos.xy;
    gl_Position    = pos * ub.value;
    feedback_value = length(pos.xy);
  }
};
enum FragmentShaderSource = ShaderHeader~q{
  in vec2 uv;

  layout(std140) uniform uniformblock {
    float value;
  } ub;

  layout(location = 1) uniform sampler2D tex;

  out vec4 color;

  void main() {
    color = texture(tex, uv);
  }
};

void Test() {
  auto tex = Texture2D.Create();
  {
    auto data = new ubyte[16*16];
    data[] = ubyte.max;

    Texture2DAllocator allocator;
    allocator.internalFormat = GL_RGBA8;
    allocator.size           = vec2i(16, 16);
    allocator.format         = GL_RED;
    allocator.type           = GL_UNSIGNED_BYTE;
    allocator.data           = data.ptr;
    allocator.Allocate(tex);
  }

  auto sampler = Sampler.Create();
  {
    SamplerConfigurer configurer;
    configurer.filterMin = GL_NEAREST;
    configurer.filterMag = GL_NEAREST;
    configurer.Configure(sampler);
  }

  auto buf = ArrayBuffer.Create();
  {
    ArrayBufferAllocator allocator;
    allocator.size  = float.sizeof*4*3;
    allocator.data  = null;
    allocator.usage = GL_STATIC_DRAW;
    allocator.Allocate(buf);

    auto ptr = buf.MapToWrite!float();
    ptr[0] = 0;
    ptr[1] = 0;
    ptr[2] = 0;
    ptr[3] = 1;

    ptr[4] = 0.5;
    ptr[5] = 0.5;
    ptr[6] = 0;
    ptr[7] = 1;

    ptr[8]  = 0.5;
    ptr[9]  = 0;
    ptr[10] = 0;
    ptr[11] = 1;
  }

  auto buf_tf = ArrayBuffer.Create();
  {
    ArrayBufferAllocator allocator;
    allocator.size  = float.sizeof * 3;
    allocator.data  = null;
    allocator.usage = GL_STREAM_COPY;
    allocator.Allocate(buf_tf);
  }

  auto ub = UniformBuffer.Create();
  {
    const data = 1.5f;
    UniformBufferAllocator allocator;
    allocator.size  = float.sizeof;
    allocator.data  = &data;
    allocator.usage = GL_STATIC_DRAW;
    allocator.Allocate(ub);
  }

  ProgramRef program;
  {
    ProgramLinker linker;
    linker.vertex              = VertexShader.Compile(VertexShaderSource);
    linker.fragment            = FragmentShader.Compile(FragmentShaderSource);
    linker.feedbackVaryings    = ["feedback_value"];
    linker.feedbackInterleaved = true;
    program = linker.Link();
    program.NumberUniformBlocks!(["uniformblock"]);

    program.Use();
    program.uniform!1 = 0;
  }

  auto va = VertexArray.Create();
  {
    va.Bind();
    VertexArrayAttacher attacher;
    attacher.index     = 0;
    attacher.type      = GL_FLOAT;
    attacher.dimension = 4;
    attacher.Attach(va, buf);
  }

  auto rb = Renderbuffer.Create();
  {
    RenderbufferAllocator allocator;
    allocator.format = GL_RGB8;
    allocator.size   = vec2i(32, 32);
    allocator.Allocate(rb);
  }

  auto fb = Framebuffer.Create();
  {
    fb.Bind();
    fb.attachment!GL_COLOR_ATTACHMENT0 = rb;
    fb.attachmentOrder = [GL_COLOR_ATTACHMENT0];
    fb.Validate();
    fb.Unbind();
  }

  buf_tf.BindForTransformFeedback(0);
  ub.BindForUniformBlock(0);
  tex.BindToUnit(GL_TEXTURE0);
  sampler.Bind(0);

  gl.BeginTransformFeedback(GL_POINTS);
  gl.PointSize(5);
  gl.DrawArrays(GL_POINTS, 0, 3);
  gl.EndTransformFeedback();

  {
    auto ptr = buf_tf.MapToRead!float();
    static foreach (i; 0..3) ptr[i].writeln;
  }
}

void main() {
  (loadSDL() == sdlSupport).
    enforce("SDL library loading failed.");

  SDL_Init(SDL_INIT_VIDEO);
  scope(exit) SDL_Quit();

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

  auto win = SDL_CreateWindow("gl4d testing", 0, 0, 100, 100, SDL_WINDOW_OPENGL).
    enforce("Failed creating OpenGL window.");
  scope(exit) SDL_DestroyWindow(win);

  auto context = SDL_GL_CreateContext(win);
  SDL_GL_MakeCurrent(win, context);
  gl.ApplyContext();

  Test();

  SDL_GL_SwapWindow(win);
  SDL_Delay(3000);
}
