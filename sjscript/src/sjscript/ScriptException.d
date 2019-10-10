/// License: MIT
module sjscript.ScriptException;

import dast.tokenize;

///
class ScriptException : Exception {
 public:
  ///
  this(string msg, TokenPos pos, string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
    this.pos = pos;
  }
  ///
  this(
      string msg, size_t stline, size_t stchar,
      string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
    pos = TokenPos(stline, stline, stchar, stchar+1);
  }
  const TokenPos pos;
}
