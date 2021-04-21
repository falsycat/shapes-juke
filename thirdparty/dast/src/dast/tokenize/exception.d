/// License: MIT
module dast.tokenize.exception;

import std.format;

///
class TokenizeException : Exception {
 public:
  ///
  this(string msg,
       size_t srcline,
       size_t srchar,
       string src  = "",
       string file = __FILE__,
       size_t line = __LINE__) {
    if (src == "") {
      msg ~= " at (%d, %d)".format(srcline, srcchar);
    } else {
      msg ~= " at token '%s' (%d, %d)".format(src, srcline, srcchar);
    }
    super(msg, file, line);

    this.srcline = srcline;
    this.srcchar = srcchar;
  }

  ///
  const size_t srcline;
  ///
  const size_t srcchar;
}
