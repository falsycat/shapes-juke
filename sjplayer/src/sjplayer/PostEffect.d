/// License: MIT
module sjplayer.PostEffect;

import std.string;

import gl4d;

///
class PostEffect {
 public:
  ///
  struct Instance {
   public:
    ///
    align(1) vec2 clip_lefttop = vec2(1, 1);
    ///
    align(1) vec2 clip_righttop = vec2(1, 1);
  }

  ///
  this(PostEffectProgram program, vec2i sz) {
    size_    = sz;
    program_ = program;
    fb_      = Framebuffer.Create();
    tex_     = TextureRect.Create();
    sampler_ = Sampler.Create();

    TextureRectAllocator allocator;
    with (allocator) {
      internalFormat = GL_RGB;
      size           = sz;
      format         = GL_RED;
      type           = GL_UNSIGNED_BYTE;
      data           = null;
      Allocate(tex_);
    }

    SamplerConfigurer configurer;
    with (configurer) {
      filterMin = GL_NEAREST;
      filterMag = GL_NEAREST;
      Configure(sampler_);
    }

    fb_.Bind();
    fb_.attachment!(GL_COLOR_ATTACHMENT0, 0, GL_TEXTURE_RECTANGLE) = tex_;
    fb_.attachmentOrder = [GL_COLOR_ATTACHMENT0];
    fb_.Validate();
    fb_.Unbind();
  }

  ///
  void BindFramebuffer() {
    fb_.Bind();
  }
  ///
  void UnbindFramebuffer() {
    fb_.Unbind();
  }
  ///
  void DrawFramebuffer() {
    program_.Draw(tex_, sampler_, instance, size_);
  }

  Instance instance;

 private:
  const vec2i size_;

  PostEffectProgram program_;

  FramebufferRef fb_;

  TextureRectRef tex_;

  SamplerRef sampler_;
}

///
class PostEffectProgram {
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
    layout(location = 0) uniform sampler2DRect fb;
    layout(location = 1) uniform ivec2         fb_size;

    layout(std140) uniform Instance {
      vec2  clip_lefttop;
      vec2  clip_rightbottom;
    } instance;

    in vec2  uv_;

    out vec4 pixel_;

    void main() {
      vec2 tex_uv = (uv_ + vec2(1, 1)) / 2;
      pixel_ = texture(fb, fb_size * tex_uv);

      pixel_.a *=
        step(-instance.clip_lefttop.x, uv_.x) *
        (1-step(instance.clip_rightbottom.x, uv_.x)) *
        (1-step(instance.clip_lefttop.y, uv_.y)) *
        step(-instance.clip_rightbottom.y, uv_.x);
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
    ubo_   = UniformBuffer.Create();

    ubo_index_ = gl.GetUniformBlockIndex(program_.id, "Instance".toStringz);

    vao_.Bind();
    VertexArrayAttacher attacher;
    with (attacher) {
      index     = 0;
      type      = GL_FLOAT;
      dimension = 2;
      Attach(vao_, verts_);
    }

    verts_.Bind();
    ArrayBufferAllocator verts_allocator;
    with (verts_allocator) {
      const v = [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1),];
      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }

    ubo_.Bind();
    UniformBufferAllocator ub_allocator;
    with (ub_allocator) {
      size  = PostEffect.Instance.sizeof;
      usage = GL_DYNAMIC_DRAW;
      Allocate(ubo_);
    }
  }

  ///
  void Draw(
      ref TextureRectRef fb,
      ref SamplerRef sampler,
      ref PostEffect.Instance instance,
      vec2i size) {
    program_.Use();

    fb.BindToUnit(GL_TEXTURE0);
    sampler.Bind(0);
    program_.uniform!0 = 0;
    program_.uniform!1 = size;

    {
      auto ptr = ubo_.MapToWrite!(PostEffect.Instance);
      *ptr = instance;
    }
    ubo_.BindForUniformBlock(ubo_index_);

    vao_.Bind();
    gl.DrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }

 private:
  ProgramRef program_;

  ArrayBufferRef verts_;

  VertexArrayRef vao_;

  UniformBufferRef ubo_;

  const GLuint ubo_index_;
}