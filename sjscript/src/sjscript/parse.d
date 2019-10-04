/// License: MIT
module sjscript.parse;

import std.conv,
       std.range.primitives;

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
      a  = 2 * distance(player_x, player_y);
      b += 0;
    }
EOS";

  src.
    Tokenize!TokenType.
    filter!(x => x.type != TokenType.Whitespace).
    chain([Token("", TokenType.End)]).
    Parse();
}

///
ParametersBlock[] Parse(R)(R tokens)
    if (isInputRange!R && is(ElementType!R == Token)) {
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

  static Expression ParseExpressionFromFirstTerm(Term term) {
    return Expression([term]);
  }
  static Expression ParseExpressionFromFollowingAddedTerm(
      Expression expr, @(TokenType.Add) Token, Term term) {
    return expr + term;
  }
  static Expression ParseExpressionFromFollowingSubtractedTerm(
      Expression expr, @(TokenType.Sub) Token, Term term) {
    return expr - term;
  }

  static Term ParseNumberTerm(@(TokenType.Number) Token number) {
    return Term([Term.Value(number.text.to!float)], []);
  }
  static Term ParseVariableTerm(@(TokenType.Ident) Token var) {
    return Term([Term.Value(var.text)], []);
  }
  static Term ParseFunctionCallTerm(FunctionCall fcall) {
    return Term([Term.Value(fcall)], []);
  }
  static Term ParseExpressionTerm(
      @(TokenType.OpenParen) Token,
      Expression expr,
      @(TokenType.CloseParen) Token) {
    return Term([Term.Value(expr)], []);
  }

  static Term ParseTermFromMultipledTerm(
      Term lterm, @(TokenType.Mul) Token, Term rterm) {
    return lterm * rterm;
  }
  static Term ParseTermFromDividedTerm(
      Term lterm, @(TokenType.Div) Token, Term rterm) {
    return lterm / rterm;
  }

  static FunctionCall ParseFunctionCall(
      @(TokenType.Ident) Token name,
      @(TokenType.OpenParen) Token,
      FunctionCallArgs args,
      @(TokenType.CloseParen) Token) {
    return FunctionCall(name.text, args.exprs);
  }
  static FunctionCallArgs ParseFunctionCallArgsFirstItem(Expression expr) {
    return FunctionCallArgs([expr]);
  }
  static FunctionCallArgs ParseFunctionCallArgsFollowingItem(
      FunctionCallArgs args, @(TokenType.Comma) Token, Expression expr) {
    return FunctionCallArgs(args.exprs ~ expr);
  }
}

private struct Whole {
  ParametersBlock[] blocks;
}
private struct FunctionCallArgs {
  Expression[] exprs;
}

private TokenPos CreateTokenPos(Token first, Token last) {
  return TokenPos(
      first.pos.stline, last.pos.edline,
      first.pos.stchar, last.pos.edchar);
}
