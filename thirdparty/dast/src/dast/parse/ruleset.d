/// License: MIT
module dast.parse.ruleset;

import std.algorithm,
       std.array,
       std.meta,
       std.range.primitives,
       std.traits;

import dast.tokenize;

import dast.parse.rule;

///
unittest {
  import std;
  import dast.util.range;

  enum TokenType {
    Number,
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
    string ParseStr(@(TokenType.Ident) Token) {
      assert(false);
    }
    string ParseStrFromFloat(float) {
      assert(false);
    }
    float ParseFloat(@(TokenType.Number) Token) {
      assert(false);
    }
    float ParseFloatFromStr(@(TokenType.Ident) Token, string, @(TokenType.Ident) Token) {
      assert(false);
    }
  }

  enum rules = CreateRulesFromRuleSet!(RuleSet, TokenType)();
  static assert(rules.length == 5);

  enum firsts = rules.CreateFirstSet!TokenType(typeid(int)).DropDuplicated;
  static assert(firsts.equal([TokenType.Ident, TokenType.Number]));
}

/// A struct which is attributed to rule methods.
struct ParseRule {}

/// Creates rules from RuleSet's methods attributed by ParseRule.
NamedRule!TokenType[] CreateRulesFromRuleSet(RuleSet, TokenType)() {
  alias members = __traits(allMembers, RuleSet);

  NamedRule!TokenType[] result;  // Appender causes CTFE errors :(

  static foreach (name; members) {{
    enum method = "RuleSet." ~ name;
    static if (__traits(compiles, mixin(method))) {
      alias attrs = __traits(getAttributes, mixin(method));
      static if (staticIndexOf!(ParseRule, attrs) >= 0) {
        static assert(__traits(getOverloads, RuleSet, name).length == 1);
        auto rule = Rule!TokenType.
          CreateFromNonOverloadedMethod!(RuleSet, name);
        result ~= NamedRule!TokenType(name, rule);
      }
    }
  }}
  return result;
}

/// Creates a first set of the target.
///
/// Items in the result can be duplicated.
TokenType[] CreateFirstSet(TokenType, R)(R rules, TypeInfo target, TypeInfo[] skip_types = [])
    if (isInputRange!R && is(Unqual!(ElementType!R) : Rule!TokenType)) {
  auto result = appender!(TokenType[]);
  skip_types ~= target;

  foreach (const ref rule; rules.filter!(x => x.lhs is target)) {
    const first = rule.rhs[0];
    if (first.isTerminal) {
      result ~= first.terminalType;
    } else if (!skip_types.canFind!"a is b"(first.nonTerminalType)) {
      result ~= rules.
        CreateFirstSet!(TokenType)(first.nonTerminalType, skip_types);
      skip_types ~= first.nonTerminalType;
    }
  }
  return result.array;
}
