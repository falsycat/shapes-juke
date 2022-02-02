/// License: MIT
module sjscript.Token;

import std.algorithm,
       std.array,
       std.ascii,
       std.conv;

import dast.tokenize;

///
unittest {
  import std;

  with (TokenType) {
    assert("0 0.1 _hoge0_ $hoge // hoge".
        Tokenize!TokenType.
        map!"a.type".
        filter!(x => x != Whitespace).
        equal([Number, Number, Ident, PreprocessCommand, Comment]));
  }
}

///
alias TokenPos = dast.tokenize.TokenPos;

///
enum TokenType {
  @TextFuncMatcher!((string text) {
      const integral_len = text.countUntil!(x => !x.isDigit);
      if (integral_len <  0) return text.length;
      if (integral_len == 0) return 0;

      if (text[integral_len]      != '.') return integral_len;
      if (text[integral_len+1..$] == "")  return integral_len;

      const fraction_len =
        text[integral_len+1..$].countUntil!(x => !x.isDigit);
      if (fraction_len <  0) return text.length;
      if (fraction_len == 0) return integral_len;

      return integral_len + 1 + fraction_len;
    }) Number,

  @TextFuncMatcher!((string text) {
      if (text.length == 0) return 0;
      if (!text[0].isAlpha && text[0] != '_') return 0;

      const index = text[1..$].countUntil!(x => !x.isAlpha && !x.isDigit && x != '_');
      return index >= 0? index.to!size_t+1: text.length;
    }) Ident,

  @TextFuncMatcher!((string text) {
      if (text.length < 2 || text[0] != '$') return 0;
      if (!text[1].isAlpha && text[1] != '_') return 0;

      const index = text[2..$].countUntil!(x => !x.isAlpha && !x.isDigit && x != '_');
      return index >= 0? index.to!size_t+2: text.length;
    }) PreprocessCommand,

  @TextCompleteMatcher!"{" OpenBrace,
  @TextCompleteMatcher!"}" CloseBrace,

  @TextCompleteMatcher!"[" OpenBracket,
  @TextCompleteMatcher!"]" CloseBracket,

  @TextCompleteMatcher!"(" OpenParen,
  @TextCompleteMatcher!")" CloseParen,

  @TextCompleteMatcher!"," Comma,
  @TextCompleteMatcher!";" SemiColon,

  @TextCompleteMatcher!".." DoubleDot,

  @TextCompleteMatcher!"="  Assign,
  @TextCompleteMatcher!"+=" AddAssign,
  @TextCompleteMatcher!":=" ColonAssign,

  @TextCompleteMatcher!"+" Add,
  @TextCompleteMatcher!"-" Sub,
  @TextCompleteMatcher!"*" Mul,
  @TextCompleteMatcher!"/" Div,

  @TextAllMatcher!isWhite Whitespace,
  @TextFuncMatcher!((string text) {
      if (text.length < 2 || text[0..2] != "//") return 0;

      const index = text.countUntil('\n');
      return index >= 0? index.to!size_t: text.length;
    }) Comment,

  End,
}

///
alias Token = dast.tokenize.Token!(TokenType, string);
