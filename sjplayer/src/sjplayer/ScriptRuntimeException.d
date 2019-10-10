/// License: MIT
module sjplayer.ScriptRuntimeException;

import sjscript;

///
class ScriptRuntimeException : Exception {
 public:
  ///
  this(
      string msg, size_t srcline, size_t srcchar,
      string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
    this.srcline = srcline;
    this.srcchar = srcchar;
  }

  ///
  size_t srcline, srcchar;
}
