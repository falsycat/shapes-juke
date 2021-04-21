/// License: MIT
module gl4d.gl;

import std.conv,
       std.exception,
       std.format;

public import bindbc.opengl;

/// This class is just for separating gl functions from the global namespace.
abstract class gl {
 public:
  /// This library requires this version.
  enum RequiredVersion = GLSupport.gl33;

  /// Applies current OpenGL context for gl4d features.
  ///
  /// If the context version is not equal to RequiredVersion,
  /// an exception will be thrown.
  static void ApplyContext() {
    const loaded = loadOpenGL();
    (RequiredVersion == loaded).
      enforce("Loading OpenGL failed with GLSupport %s. (expected %s)".
          format(loaded, RequiredVersion));
  }

  /// Calls OpenGL function with error handling.
  static auto opDispatch(string func,
      string file = __FILE__, size_t line = __LINE__, Args...)(Args args) {
    scope (exit) {
      auto err = glGetError();
      (err == GL_NO_ERROR).
        enforce(GetErrorString(err), file, line);
    }
    return mixin("gl"~func~"(args)");
  }

 private:
  static string GetErrorString(GLenum err) {
    switch (err) {
      case GL_NO_ERROR:
        return "GL_NO_ERROR "~
          "(No error has been recorded."~
          " The value of this symbolic constant is guaranteed to be 0.)";
      case GL_INVALID_ENUM:
        return "GL_INVALID_ENUM "~
          "(An unacceptable value is specified for an enumerated argument."~
          " The offending command is ignored and has no other side effect than to set the error flag.)";
      case GL_INVALID_VALUE:
        return "GL_INVALID_VALUE "~
          "(A numeric argument is out of range. "~
          "The offending command is ignored and has no other side effect than to set the error flag.)";
      case GL_INVALID_OPERATION:
        return "GL_INVALID_OPERATION "~
          "(The specified operation is not allowed in the current state."~
          " The offending command is ignored and has no other side effect than to set the error flag.)";
      case GL_OUT_OF_MEMORY:
        return "GL_OUT_OF_MEMORY "~
          "(There is not enough memory left to execute the command."~
          " The state of the GL is undefined, except for the state of the error flags, after this error is recorded.";
      default:
        return err.to!string;
    }
  }
}
