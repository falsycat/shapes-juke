/// License: MIT
module gl4d.Sampler;

import std.conv,
       std.typecons;

import gl4d.gl,
       gl4d.GLObject;

/// RefCounted version of Sampler.
alias SamplerRef = RefCounted!Sampler;

/// A wrapper type for OpenGL sampler.
struct Sampler {
  mixin GLObject!(
      (x, y) => gl.GenSamplers(x, y),
      void,
      (x)    => gl.DeleteSamplers(1, x)
    );

 public:
  /// Binds to the texture unit index.
  void Bind(int index) {
    assert(!empty);
    gl.BindSampler(index.to!GLuint, id);
  }
}

/// A configurer for OpenGL sampler.
struct SamplerConfigurer {
 public:
  ///
  GLenum wrapS = GL_CLAMP_TO_EDGE;
  ///
  GLenum wrapT = GL_CLAMP_TO_EDGE;
  ///
  GLenum wrapR = GL_CLAMP_TO_EDGE;

  ///
  GLenum filterMin = GL_NEAREST;
  ///
  GLenum filterMag = GL_NEAREST;

  /// Configures the sampler with parameters this has.
  void Configure(ref SamplerRef sampler)
  in {
    assert(!sampler.empty);
  }
  do {
    gl.SamplerParameteri(sampler.id, GL_TEXTURE_WRAP_S, wrapS);
    gl.SamplerParameteri(sampler.id, GL_TEXTURE_WRAP_T, wrapT);
    gl.SamplerParameteri(sampler.id, GL_TEXTURE_WRAP_R, wrapR);

    gl.SamplerParameteri(sampler.id, GL_TEXTURE_MIN_FILTER, filterMin);
    gl.SamplerParameteri(sampler.id, GL_TEXTURE_MAG_FILTER, filterMag);
  }
}
