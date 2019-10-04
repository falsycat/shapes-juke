/// License: MIT
module sjscript.Token;

import std.algorithm,
       std.array,
       std.ascii;

import dast.tokenize;

///
alias TokenPos = dast.tokenize.TokenPos;

///
enum TokenType {
  @TextFuncMatcher!((string text, string next) {
      const point_index = text.countUntil('.');
      if (point_index < 0) {
        if (text.all!isDigit) {
          if (next.length == 1 && (next[0].isDigit || next[0] == '.')) {
            return TextMatchResult.Probably;
          }
          return TextMatchResult.Completely;
        }
      } else {
        if ((text[0..point_index]~text[point_index+1..$]).all!isDigit) {
          if (next.length == 1 && next[0].isDigit) {
            return TextMatchResult.Probably;
          }
          return TextMatchResult.Completely;
        }
      }
      return TextMatchResult.Improbably;
    }) Number,

  @TextFuncMatcher!((string text, string next) {
      const head = text[0].isAlpha || text[0] == '_';
      const body = text[1..$].all!(
          x => x.isAlpha || x.isDigit || x == '_');
      const nexthead = next.length > 0 && (
          next[0].isAlpha || next[0].isDigit || next[0] == '_');

      if (head && body && !nexthead) return TextMatchResult.Completely;
      if (head && body &&  nexthead) return TextMatchResult.Probably;
      return TextMatchResult.Improbably;
    }) Ident,

  @TextFuncMatcher!((string text, string next) {
      const head = text[0] == '$';
      if (!head || text.length <= 1) {
        return head? TextMatchResult.Probably: TextMatchResult.Improbably;
      }
      if (text[1] != '_' && !text[1].isAlpha) {
        return TextMatchResult.Improbably;
      }
      if (text[1..$].all!(x => x.isAlpha || x.isDigit || x == '_')) {
        if (next.length > 0 && (next[0].isAlpha || next[0].isDigit || next[0] == '_')) {
          return TextMatchResult.Probably;
        }
        return TextMatchResult.Completely;
      }
      return TextMatchResult.Improbably;
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

  @TextCompleteMatcher!"+" Add,
  @TextCompleteMatcher!"-" Sub,
  @TextCompleteMatcher!"*" Mul,
  @TextCompleteMatcher!"/" Div,

  @TextAllMatcher!isWhite Whitespace,

  End,
}
///
unittest {
  with (TokenType) {
    "0 0.1 _hoge0_ $hoge".Tokenize!TokenType.map!"a.type".equal(
        [Number, Whitespace, Number, Whitespace, Ident, Whitespace, PreprocessCommand]);
  }
}

///
alias Token = dast.tokenize.Token!(TokenType, string);
