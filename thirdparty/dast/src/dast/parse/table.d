/// License: MIT
module dast.parse.table;

import std.algorithm;

import dast.parse.itemset,
       dast.parse.rule,
       dast.parse.ruleset;

///
unittest {
  import std;

  enum TokenType {
    Ident,
    End,
  }
  alias Token = dast.tokenize.Token!(TokenType, string);

  struct RuleSet {
   public:
   @ParseRule:
    int ParseWhole(string, @(TokenType.End) Token) {
      assert(false);
    }
    string ParseString(@(TokenType.Ident) Token) {
      assert(false);
    }
  }

  enum rules   = CreateRulesFromRuleSet!(RuleSet, TokenType)();
  enum itemset = rules.CreateItemSetFromRules(typeid(int));
  enum table   = itemset.CreateTableFromItemSet();
}

///
struct Table(TokenType) if (is(TokenType == enum)) {
 public:
  ///
  const size_t[TokenType][] shift;
  ///
  const string[TokenType][] reduce;
  ///
  const size_t[TypeInfo][] go;

  ///
  const size_t accept_state;
}

///
Table!(T.TokenType) CreateTableFromItemSet(T)(in ItemSet!T itemset) {
  size_t[T.TokenType][] shift;
  string[T.TokenType][] reduce;
  size_t[TypeInfo][] go;

  size_t accept_state;

  shift.length  = itemset.automaton.length;
  reduce.length = itemset.automaton.length;
  go.length     = itemset.automaton.length;

  foreach (state, numbers; itemset.automaton) {
    foreach (k, v; numbers) {
      const term = itemset.terms[k];
      if (term.isTerminal) {
        shift[state][term.terminalType] = v;
      } else {
        go[state][term.nonTerminalType] = v;
      }
    }
  }

  foreach (state, rules; itemset.states) {
    foreach (rule; rules.filter!"!a.canAdvance") {
      if (rule.lhs is itemset.whole) accept_state = state;
      rule.follows.each!(x => reduce[state][x] = rule.name);
    }
  }
  return Table!(T.TokenType)(shift, reduce, go, accept_state);
}
