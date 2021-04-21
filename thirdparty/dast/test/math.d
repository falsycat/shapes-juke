#!/usr/bin/env dub
/+ dub.json:
{
  "name": "math",
  "dependencies": {
    "dast": {"path": "../"}
  }
} +/

import std;
import dast.parse,
       dast.tokenize;

enum TokenType {
  @TextAllMatcher!isDigit Number,

  @TextCompleteMatcher!"+" Add,
  @TextCompleteMatcher!"-" Sub,
  @TextCompleteMatcher!"*" Mul,
  @TextCompleteMatcher!"/" Div,

  @TextCompleteMatcher!"(" OpenParen,
  @TextCompleteMatcher!")" CloseParen,

  End,
}
alias Token = dast.tokenize.Token!(TokenType, string);

struct Whole {
  int result;
}
struct TermList {
  int value;
}
struct Term {
  int value;
}

class RuleSet {
 public:
 @ParseRule:
  static Whole ParseWhole(TermList terms, @(TokenType.End) Token) {
    return Whole(terms.value);
  }

  static TermList ParseTermListFromAddedNextTerm(
      TermList lterms, @(TokenType.Add) Token, Term term) {
    return TermList(lterms.value + term.value);
  }
  static TermList ParseTermListFromSubtractedNextTerm(
      TermList lterms, @(TokenType.Sub) Token, Term term) {
    return TermList(lterms.value - term.value);
  }
  static TermList ParseTermListFirstItem(Term term) {
    return TermList(term.value);
  }

  static Term ParseTermFromFirstNumber(@(TokenType.Number) Token num) {
    return Term(num.text.to!int);
  }

  static Term ParseTermFromTermList(
      @(TokenType.OpenParen) Token, TermList terms, @(TokenType.CloseParen) Token) {
    return Term(terms.value);
  }
  static Term ParseMultipledTerm(
      Term lterm, @(TokenType.Mul) Token, @(TokenType.Number) Token num) {
    return Term(lterm.value * num.text.to!int);
  }
  static Term ParseDividedTerm(
      Term lterm, @(TokenType.Div) Token, @(TokenType.Number) Token num) {
    return Term(lterm.value / num.text.to!int);
  }
}

void main(string[] args) {
  assert(args.length == 2);

  // PrintItemSet!(TokenType, RuleSet, Whole);

  try {
    args[1].
      Tokenize!TokenType.
      chain([Token("", TokenType.End)]).
      Parse!Whole(cast(RuleSet) null).
      result.writeln;
  } catch (ParseException!Token e) {
    "%s at token '%s' [%s] at (%d, %d)".
      writefln(e.msg, e.token.text, e.token.type, e.token.pos.stline, e.token.pos.stchar);
  }
}
