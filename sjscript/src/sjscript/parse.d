/// License: MIT
module sjscript.parse;

import std.conv;

import dast.parse;

import sjscript.Expression,
       sjscript.ParametersBlock,
       sjscript.Token;

///
unittest {
  import std;
  import dast.tokenize : Tokenize;

  enum src = q"EOS
    framebuffer [0..5] {
      a = 0;
      b += 0;
    }
EOS";
  try {
    src.
      Tokenize!TokenType.
      filter!(x => x.type != TokenType.Whitespace).
      chain([Token("", TokenType.End)]).
      Parse().
      each!writeln;
  } catch (ParseException!Token e) {
    "%s at %s".writefln(e.msg, e.token);
  }
}

///
ParametersBlock[] Parse(R)(R tokens) {
  return dast.parse.Parse!Whole(tokens, cast(RuleSet) null).blocks;
}

private class RuleSet {
 public:
 @ParseRule:
  static Whole ParseWhole(ParametersBlock[] blocks, @(TokenType.End) Token) {
    return Whole(blocks);
  }

  static ParametersBlock[] ParseParametersBlockListFirstItem(ParametersBlock block) {
    return [block];
  }
  static ParametersBlock[] ParseParametersBlockListFollowingItem(
      ParametersBlock[] blocks, ParametersBlock block) {
    return blocks ~ block;
  }

  static ParametersBlock ParseParametersBlock(
      @(TokenType.Ident) Token target,
      Period period,
      @(TokenType.OpenBrace) Token,
      Parameter[] params,
      @(TokenType.CloseBrace) Token closebrace) {
    return ParametersBlock(
        target.text, period, params, CreateTokenPos(target, closebrace));
  }

  static Period ParsePeriod(
      @(TokenType.OpenBracket) Token,
      @(TokenType.Number) Token begin,
      @(TokenType.DoubleDot) Token,
      @(TokenType.Number) Token end,
      @(TokenType.CloseBracket) Token) {
    return Period(
        begin.text.to!float.to!int, end.text.to!float.to!int);
  }

  static Parameter[] ParseParameterListFirstItem(Parameter param) {
    return [param];
  }
  static Parameter[] ParseParameterListFollowingItem(
      Parameter[] params, Parameter param) {
    return params ~ param;
  }

  static Parameter ParseAssignParameter(
      @(TokenType.Ident) Token ident,
      @(TokenType.Assign) Token,
      Expression expr,
      @(TokenType.SemiColon) Token semicolon) {
    return Parameter(
        ident.text, ParameterType.Assign, expr, CreateTokenPos(ident, semicolon));
  }
  static Parameter ParseAddAssignParameter(
      @(TokenType.Ident) Token ident,
      @(TokenType.AddAssign) Token,
      Expression expr,
      @(TokenType.SemiColon) Token semicolon) {
    return Parameter(
        ident.text, ParameterType.AddAssign, expr, CreateTokenPos(ident, semicolon));
  }

  static Expression ParseExpression(@(TokenType.Number) Token) {  // TODO
    return Expression();
  }
}

private struct Whole {
  ParametersBlock[] blocks;
}

private TokenPos CreateTokenPos(Token first, Token last) {
  return TokenPos(
      first.pos.stline, last.pos.edline,
      first.pos.stchar, last.pos.edchar);
}
