/// License: MIT
module dast.parse;

import std.algorithm,
       std.conv,
       std.range.primitives,
       std.traits,
       std.variant;

import dast.tokenize;

import dast.parse.itemset,
       dast.parse.rule,
       dast.parse.ruleset,
       dast.parse.table;

public {
  import dast.parse.exception,
         dast.parse.ruleset;
}

///
unittest {
  import std;

  enum TokenType {
    Unknown,

    @TextCompleteMatcher!"," Comma,

    @TextAllMatcher!isDigit Number,
    @TextAllMatcher!isWhite Whitespace,

    End,
  }
  alias Token = dast.tokenize.Token!(TokenType, string);

  struct Whole {
    int[] numbers;
  }
  class RuleSet {
   public:
   @ParseRule:
    Whole ParseWhole(int[] nums, @(TokenType.End) Token) {
      return Whole(nums);
    }
    int[] ParseFirstNumber(@(TokenType.Number) Token num) {
      return [num.text.to!int];
    }
    int[] ParseNextNumber(int[] nums, @(TokenType.Comma) Token, @(TokenType.Number) Token num) {
      return nums ~ num.text.to!int;
    }
  }

  auto ruleset = new RuleSet;

  int[] ParseNumbers(string src) {
    return src.
      Tokenize!TokenType.
      filter!(x => x.type != TokenType.Whitespace).
      chain([Token("", TokenType.End)]).
      Parse!Whole(ruleset).numbers;
  }
  assert(ParseNumbers("0, 1, 2, 3").equal([0, 1, 2, 3]));

  assertThrown!(ParseException!Token)(ParseNumbers("0 1 2 3"));
}

///
Whole Parse(Whole, Tokenizer, RuleSet)(Tokenizer tokenizer, RuleSet ruleset)
    if (isInputRange!Tokenizer && IsToken!(ElementType!Tokenizer)) {
  alias Token     = ElementType!Tokenizer;
  alias Exception = ParseException!Token;

  enum rules = CreateRulesFromRuleSet!(RuleSet, Token.TokenType);
  static assert(rules.length > 0);

  enum itemset  = rules.CreateItemSetFromRules(typeid(Whole));
  enum table    = itemset.CreateTableFromItemSet();
  enum statelen = table.shift.length;

  enum stackitem_size = itemset.terms.
    filter!"!a.isTerminal".
    map   !"a.nonTerminalType.tsize".
    maxElement.
    max(Token.sizeof);

  alias StackItem = VariantN!(stackitem_size);

  StackItem[] stack;
  size_t[]    status = [0];

  size_t Reduce(Token, string name)() {
    alias Func   = mixin("RuleSet."~name);
    alias Params = Parameters!Func;

    Params params;
    static foreach (parami; 0..Params.length) {
      static if (is(Params[$-parami-1] == Token)) {
        params[$-parami-1] = stack[$-parami-1].get!Token;
      } else {
        params[$-parami-1] = stack[$-parami-1].get!(Params[$-parami-1]);
      }
    }
    stack  = stack[0..$-Params.length];
    stack ~= StackItem(mixin("ruleset."~name~"(params)"));
    return Params.length;
  }

  void GoStateAfterReduce() {
    auto  stack_top_type = stack[$-1].type;
    const current_status = status[$-1];

    TypeInfo temp;
    static foreach (statei; 0..statelen) {
      if (statei == current_status) {
        static foreach (type, number; table.go[statei]) {
          if (type is stack_top_type) {
            status ~= table.go[statei][stack_top_type];
            return;
          }
        }
      }
    }
    assert(false);  // broken go table
  }

  Token prev_token;
  while (status[$-1] != table.accept_state) {
    if (tokenizer.empty) {
      throw new Exception("all tokens are consumed without acception", prev_token);
    }
    const token = tokenizer.front;
    scope(exit) prev_token = token;

MAIN_SWITCH: switch (status[$-1]) {
      static foreach (statei; 0..statelen) {
        case statei:
          static foreach (token_type, reduce; table.reduce[statei]) {
            if (token_type == token.type) {
              const pop = Reduce!(Token, reduce);
              status    = status[0..$-pop];
              GoStateAfterReduce();
              break MAIN_SWITCH;
            }
          }
          static foreach (token_type, shift; table.shift[statei]) {
            if (token_type == token.type) {
              stack  ~= StackItem(cast(Unqual!Token) token);
              status ~= shift;
              tokenizer.popFront();
              break MAIN_SWITCH;
            }
          }
          throw new Exception("unexpected token", token);
      }
      default: assert(false);
    }
  }

  Reduce!(Token, itemset.states[0][0].name);
  return stack[0].get!Whole;
}

debug void PrintItemSet(TokenType, RuleSet, Whole)()
    if (is(TokenType == enum)) {
  import std;

  enum itemset =
    CreateRulesFromRuleSet!(RuleSet, TokenType).
    CreateItemSetFromRules(typeid(Whole));

  void PrintTerm(T2)(T2 term) {
    if (term.isTerminal) {
      term.terminalType.write;
    } else {
      term.nonTerminalType.write;
    }
  }

  "[states]".writeln;
  foreach (statei, state; itemset.states) {
    "  (%d) ".writef(statei);
    foreach (termi, go; itemset.automaton[statei]) {
      PrintTerm(itemset.terms[termi]);
      ":%d, ".writef(go);
    }
    writeln;

    foreach (rule; state) {
      "    %s => ".writef(rule.lhs);
      foreach (termi, term; rule.rhs) {
        if (termi == rule.cursor) "/ ".write;
        PrintTerm(term);
        " ".write;
      }
      if (rule.rhs.length == rule.cursor) "/ ".write;
      rule.follows.writeln;
    }
  }
}
