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
    align(1) float raster_fineness = 0;
    ///
    align(1) float raster_width = 0;

    ///
    align(1) vec2 clip_lefttop = vec2(0, 0);
    ///
    align(1) vec2 clip_rightbottom = vec2(0, 0);
  }

  ///
  this(PostEffectProgram program, vec2i sz) {
    size_    = sz;
    program_ = program;
    fb_      = Framebuffer.Create();
    tex_     = TextureRect.Create();
    sampler_ = Sampler.Create();

    with (TextureRectAllocator()) {
      internalFormat = GL_RGB;
      size           = sz;
      format         = GL_RED;
      type           = GL_UNSIGNED_BYTE;
      data           = null;
      Allocate(tex_);
    }

    with (SamplerConfigurer()) {
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

  ///
  Instance instance;
  alias instance this;

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
      float raster_fineness;
      float raster_width;

      vec2  clip_lefttop;
      vec2  clip_rightbottom;
    } instance;

    in vec2  uv_;

    out vec4 pixel_;

    void main() {
      vec2 uv = uv_;

      // raster
      uv.x += sin(uv.y*instance.raster_fineness) * instance.raster_width;

      // getting texel
      vec2 tex_uv = (uv + vec2(1, 1)) / 2;
      pixel_ = texture(fb, fb_size * tex_uv);

      // clipping
      pixel_.a *=
        step(-1+instance.clip_lefttop.x, uv_.x) *
        (1-step(1-instance.clip_rightbottom.x, uv_.x)) *
        (1-step(1-instance.clip_lefttop.y, uv_.y)) *
        step(-1+instance.clip_rightbottom.y, uv_.y);
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
    with (VertexArrayAttacher()) {
      index     = 0;
      type      = GL_FLOAT;
      dimension = 2;
      Attach(vao_, verts_);
    }

    verts_.Bind();
    with (ArrayBufferAllocator()) {
      const v = [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1),];
      data  = v.ptr;
      size  = typeof(v[0]).sizeof * v.length;
      usage = GL_STATIC_DRAW;
      Allocate(verts_);
    }

    ubo_.Bind();
    with (UniformBufferAllocator()) {
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
