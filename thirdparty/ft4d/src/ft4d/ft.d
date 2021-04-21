// License: MIT
module ft4d.ft;

import std.exception;

public import bindbc.freetype;

/// This class is just for separating ft functions from global namespace.
abstract class ft {
 public:
  /// Initializes freetype library.
  static void Initialize() {
    if (lib_) return;
    FT_Init_FreeType(&lib_).EnforceFT();
  }
  /// Disposes all resources allocated by freetype library.
  static void Dispose() {
    if (!lib_) return;
    FT_Done_FreeType(lib_).EnforceFT();
  }
  /// Checks if freetype library has already been initialized
  static @property bool IsInitialized() {
    return !!lib_;
  }

  /// Returns: a pointer to an initialized library
  static @property FT_Library lib() in (IsInitialized) {
    return lib_;
  }

 private:
  static FT_Library lib_;
}

/// Checks the result value of freetype functions and throws an exception if needed.
void EnforceFT(FT_Error i) {
  // TODO: throw with descriptions

  (i == FT_Err_Ok).enforce("unknown error");
}
