/// License: MIT
module gl4d.Framebuffer;

import std.conv,
       std.exception,
       std.typecons,
       std.variant;

import gl4d.gl,
       gl4d.math,
       gl4d.GLObject,
       gl4d.Renderbuffer,
       gl4d.Texture;

/// RefCounted version of OpenGL framebuffer.
alias FramebufferRef = RefCounted!Framebuffer;

/// A variant type of types which can be framebuffers' attachments.
alias FramebufferAttachment = Algebraic!(
    Texture2DRef,
    TextureRectRef,
    RenderbufferRef
  );

/// A wrapper type for OpenGL framebuffer.
///
/// Usually this is wrapped by RefCounted.
/// When it's in default, empty() property returns true and id() property is invalid.
struct Framebuffer {
  mixin GLObject!(
      (x, y) => gl.GenFramebuffers(x, y),
      (x)    => gl.BindFramebuffer(GL_FRAMEBUFFER, x),
      (x)    => gl.DeleteFramebuffers(1, x)
    );

 public:
  ~this() {
    // Forces unrefering all buffers.
    foreach (key; attachments_.keys) {
      attachments_[key] = FramebufferAttachment.init;
    }
  }

  /// Binds this framebuffer to be read.
  void BindToRead() {
    gl.BindFramebuffer(GL_READ_FRAMEBUFFER, id);
  }
  /// Binds this framebuffer to be written.
  void BindToWrite() {
    gl.BindFramebuffer(GL_DRAW_FRAMEBUFFER, id);
  }

  /// Validates this framebuffer.
  ///
  /// This framebuffer must be bound to be written.
  void Validate() {
    const status = gl.CheckFramebufferStatus(GL_FRAMEBUFFER);
    (status == GL_FRAMEBUFFER_COMPLETE).
      enforce("The framebuffer validation failed.");
  }

 private:
  FramebufferAttachment[GLenum] attachments_;
}

/// Attaches the buffer as the attachment to the framebuffer.
///
/// The framebuffer must be bound to be written.
@property void attachment(GLenum type)(
    ref FramebufferRef fb, ref RenderbufferRef buf) {
  assert(!fb.empty);
  assert(!buf.empty);

  fb.attachments_[type] = buf;
  gl.FramebufferRenderbuffer(GL_FRAMEBUFFER, type, GL_RENDERBUFFER, buf.id);
}
/// ditto
@property void attachment(GLenum type, int miplvl = 0, GLenum target)(
    ref FramebufferRef fb, ref TextureRef!target buf)
    if (target.IsSupported2DTextureTarget) {
  assert(!fb.empty);
  assert(!buf.empty);

  fb.attachments_[type] = buf;
  gl.FramebufferTexture2D(GL_FRAMEBUFFER,
      type, target, buf.id, miplvl.to!GLint);
}

/// Changes color attachments' order.
///
/// The framebuffer must be bound to be written.
@property void attachmentOrder(ref FramebufferRef fb, GLenum[] attachments) {
  assert(!fb.empty);
  gl.DrawBuffers(attachments.length.to!GLsizei, attachments.ptr);
}
