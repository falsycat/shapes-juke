/// License: MIT
module sjplayer.PostEffect;

import gl4d;

///
class PostEffect {
 public:
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
    program_.Draw(tex_, sampler_, size_);
  }

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
      uv_         = (vert+vec2(1, 1)) / 2;
      gl_Position = vec4(vert, 0, 1);
    }
  };
  ///
  enum FragmentShaderSrc = ShaderHeader ~ q{
    layout(location = 0) uniform sampler2DRect fb;
    layout(location = 1) uniform ivec2         fb_size;

    in vec2  uv_;

    out vec4 pixel_;

    void main() {
      pixel_ = texture(fb, fb_size * uv_);
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
  }

  ///
  void Draw(ref TextureRectRef fb, ref SamplerRef sampler, vec2i size) {
    program_.Use();

    fb.BindToUnit(GL_TEXTURE0);
    sampler.Bind(0);
    program_.uniform!0 = 0;
    program_.uniform!1 = size;

    vao_.Bind();
    gl.DrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }

 private:
  ProgramRef program_;

  ArrayBufferRef verts_;

  VertexArrayRef vao_;
}
