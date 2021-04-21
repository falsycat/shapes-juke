/// License: MIT
module dast.tokenize.data;

import std.traits;

///
template IsToken(T) {
  private enum hasRequiredMembers =
    __traits(hasMember, T, "text") &&
    __traits(hasMember, T, "type") &&
    __traits(hasMember, T, "pos");

  static if (hasRequiredMembers) {
    enum IsToken =
      isSomeString!(typeof(T.text)) &&
      is(typeof(T.type) == enum) &&
      is(typeof(T.pos)  == TokenPos);
  } else {
    enum IsToken = false;
  }
}

///
enum IsToken(T, S) = IsToken!T && is(typeof(T.text) == S);

///
struct Token(TokenType_, S)
    if (is(TokenType_ == enum) && isSomeString!S) {
  alias TokenType = TokenType_;

  S         text;
  TokenType type;

  TokenPos pos;
}

///
struct TokenPos {
  size_t stline;
  size_t edline;

  size_t stchar;
  size_t edchar;
}
