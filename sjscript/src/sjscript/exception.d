/// License: MIT
module sjscript.exception;

import sjscript.Token;

///
class ScriptException : Exception {
 public:
  ///
  this(string msg, Token token, string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
    this.token = token;
  }
  const Token token;
}
///
class PreprocessException : ScriptException {
 public:
  mixin ExceptionConstructor;
}

private mixin template ExceptionConstructor() {
 public:
  this(string msg, Token token, string file = __FILE__, size_t line = __LINE__) {
    super(msg, token, file, line);
  }
}
