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
    align(4) float raster_fineness = 600;
    ///
    align(4) float raster_width = 0;

    ///
    align(8) vec2 clip_lefttop = vec2(0, 0);
    ///
    align(8) vec2 clip_rightbottom = vec2(0, 0);

    ///
    align(16) vec4 contrast = vec4(1, 1, 1, 1);

    ///
    align(16) vec4 blur = vec4(0.2, 0.2, 0.2, 0);
  }

  ///
  this(PostEffectProgram program, vec2i sz) {
    size_    = sz;
    program_ = program;
    fb_      = Framebuffer.Create();
    tex_     = TextureRect.Create();
    depth_   = Renderbuffer.Create();
    sampler_ = Sampler.Create();

    with (TextureRectAllocator()) {
      internalFormat = GL_RGB;
      size           = sz;
      format         = GL_RED;
      type           = GL_UNSIGNED_BYTE;
      data           = null;
      Allocate(tex_);
    }
    with (RenderbufferAllocator()) {
      format = GL_DEPTH_COMPONENT;
      size   = sz;
      Allocate(depth_);
    }
    with (SamplerConfigurer()) {
      filterMin = GL_NEAREST;
      filterMag = GL_NEAREST;
      Configure(sampler_);
    }

    fb_.Bind();
    fb_.attachment!(GL_COLOR_ATTACHMENT0, 0, GL_TEXTURE_RECTANGLE) = tex_;
    fb_.attachmentOrder = [GL_COLOR_ATTACHMENT0];

    fb_.attachment!GL_DEPTH_ATTACHMENT = depth_;

    fb_.Validate();
    fb_.Unbind();
  }

  ///
  void Initialize() {
    instance = instance.init;
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

  RenderbufferRef depth_;

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

      vec4 contrast;

      vec4 blur;
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

      // contrast
      pixel_.r = pow(pixel_.r, instance.contrast.r);
      pixel_.g = pow(pixel_.g, instance.contrast.g);
      pixel_.b = pow(pixel_.b, instance.contrast.b);
      pixel_.a = pow(pixel_.a, instance.contrast.a);

      // blur
      vec4 blur_div = instance.blur / 32;
      pixel_ = pixel_ * (1-instance.blur) +
        texture(fb, fb_size * tex_uv + vec2(-2,  2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2(-2,  1)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2(-2,  0)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2(-2, -1)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2(-2, -2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2(-1, -2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 0, -2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 1, -2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 2, -2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 2, -1)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 2,  0)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 2,  1)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 2,  2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 1,  2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2( 0,  2)) * blur_div +
        texture(fb, fb_size * tex_uv + vec2(-1,  2)) * blur_div +

        texture(fb, fb_size * tex_uv + vec2(-1,  1)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2(-1,  0)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2(-1, -1)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2( 0, -1)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2( 1, -1)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2( 1,  0)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2( 1,  1)) * blur_div*2 +
        texture(fb, fb_size * tex_uv + vec2( 0,  1)) * blur_div*2;

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
