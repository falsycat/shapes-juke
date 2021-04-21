/// License: MIT
module dast.tokenize;

import std.format,
       std.range,
       std.traits,
       std.typecons;

public {
  import dast.tokenize.data,
         dast.tokenize.exception,
         dast.tokenize.match;
}

///
unittest {
  import std;

  enum TokenType {
    @TextAllMatcher!isDigit Number,
    @TextAllMatcher!isAlpha Ident,
    @TextAllMatcher!isWhite Whitespace,

    @TextCompleteMatcher!"0"  Zero,
    @TextCompleteMatcher!"0a" ZeroAndA,
  }

  with (TokenType) {
    auto tokens = "1 abc 2".Tokenize!(TokenType, string)();
    assert(tokens.
        map!"a.type".
        equal([Number, Whitespace, Ident, Whitespace, Number]));
    assert(tokens.
        filter!(x => x.type != Whitespace).
        map!"a.text".
        equal(["1", "abc", "2"]));
  }
  with (TokenType) {
    auto tokens = "0a 1 2".Tokenize!(TokenType, string)();
    assert(tokens.
        map!"a.type".
        equal([ZeroAndA, Whitespace, Number, Whitespace, Number]));
    assert(tokens.
        filter!(x => x.type != Whitespace).
        map!"a.text".
        equal(["0a", "1", "2"]));
  }
  assertThrown!TokenizeException("0".Tokenize!(TokenType, string));
}

/// Tokenizes the src into the TokenType.
/// Returns: an input range of Token!(TokenType, S) as a voldemorte type
auto Tokenize(TokenType, S)(S src)
    if (is(TokenType == enum) && isSomeString!S) {
  return Tokenizer!(TokenType, S)(src).drop(1);
}

private struct Tokenizer(TokenType_, S)
  if (is(TokenType_ == enum) && isSomeString!S) {
 public:
  alias TokenType = TokenType_;
  alias Token     = dast.tokenize.data.Token!(TokenType, S);

  void PopFront() in (!empty) {
    if (cursor_ < src.length) {
      TokenizeNext();
    } else {
      end_ = true;
    }
  }
  alias popFront = PopFront;

  @property Token front() const in (!empty) {
    return last_tokenized_;
  }
  @property bool empty() const {
    return end_;
  }

  const S src;

 private:
  void TokenizeNext() in (!empty) {
    last_tokenized_.pos.stline = line_;
    last_tokenized_.pos.stchar = char_;

    const match = FindMatchedTokenTypes!TokenType(src[cursor_..$]);
    if (match.types.length == 0 || match.length == 0) {
      throw new TokenizeException(
          "found the uncategorizable token",
          line_, char_, src[cursor_..cursor_+1]);
    }
    if (match.types.length > 1) {
      throw new TokenizeException(
          "found the token which can be categorizable to multiple types %s".
            format(match.types),
          line_, char_, src[cursor_..cursor_+1]);
    }

    last_tokenized_.text = src[cursor_..cursor_+match.length];
    last_tokenized_.type = match.types[0];

    foreach (c; last_tokenized_.text) {
      ++char_;
      if (c == '\n') {
        ++line_;
        char_ = 0;
      }
    }
    cursor_ += match.length;

    last_tokenized_.pos.edline = line_;
    last_tokenized_.pos.edchar = char_;
  }

  Token last_tokenized_;

  bool end_;

  size_t cursor_;
  size_t line_, char_;
}
