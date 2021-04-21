/// License: MIT
module dast.parse.exception;

import dast.tokenize;

///
class ParseException(Token) : Exception if (IsToken!Token) {
 public:
  ///
  this(string msg, Token token, string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
    this.token = token;
  }

  Token token;
}
