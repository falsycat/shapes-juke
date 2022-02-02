/// License: MIT
module dast.parse.itemset;

import std.algorithm,
       std.array,
       std.conv,
       std.range,
       std.range.primitives,
       std.traits,
       std.typecons;

import dast.parse.rule,
       dast.parse.ruleset,
       dast.util.range;

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
}

///
struct RuleWithCursor(T) if (IsRule!T) {
 public:
  alias entity this;

  ///
  bool opEquals(in RuleWithCursor other) const {
    return
      entity == other.entity &&
      cursor == other.cursor &&
      follows.equal(other.follows);
  }

  ///
  @property RuleWithCursor advanced() const in (canAdvance) {
    return RuleWithCursor(entity, cursor+1, follows);
  }

  ///
  @property Term!(T.TokenType) prev() const in (cursor > 0) {
    return cast(Term!(T.TokenType)) entity.rhs[cursor-1];
  }
  ///
  @property Term!(T.TokenType) next() const in (canAdvance) {
    return cast(Term!(T.TokenType)) entity.rhs[cursor];
  }

  ///
  @property bool canAdvance() const {
    return cursor < entity.rhs.length;
  }

  ///
  const T entity;

  ///
  const size_t cursor;

  ///
  const T.TokenType[] follows;
}

///
struct ItemSet(T) if (IsRule!T) {
 public:
  ///
  TypeInfo whole;

  ///
  const Term!(T.TokenType)[] terms;
  ///
  const size_t[size_t][] automaton;
  ///
  const RuleWithCursor!T[][] states;
}

///
ItemSet!(ElementType!R) CreateItemSetFromRules(R)(R rules, TypeInfo whole)
    if (isInputRange!R && IsRule!(ElementType!R))
in {
  assert(rules.count!(x => x.lhs is whole) == 1);
}
do {
  alias T = ElementType!R;

  Term!(T.TokenType)[] terms;
  size_t FindOrRegisterTermIndices(typeof(terms[0]) term) {
    auto index = terms.countUntil!(x => x == term);
    if (index < 0) {
      index  = terms.length.to!(typeof(index));
      terms ~= term;
    }
    return index.to!size_t;
  }

  RuleWithCursor!T[] Resolve(
      RuleWithCursor!T[] items, TypeInfo[] prev_resolved_types = [null]) {
    auto resolved_types = prev_resolved_types.appender;

    T[] new_items;
    foreach (item; items) {
      auto type =
        !item.canAdvance || item.next.isTerminal? null: item.next.nonTerminalType;
      if (resolved_types[].canFind!"a is b"(type)) continue;

      rules.
        filter!(x => x.lhs is type).
        each  !(x => new_items ~= x);
      resolved_types ~= type;
    }

    auto result = items ~ new_items.
      map!(x => RuleWithCursor!T(x)).
      array;
    return new_items.length > 0?
      Resolve(result, resolved_types[]): result;
  }
  RuleWithCursor!T[][size_t] Advance(in RuleWithCursor!T[] items) {
    RuleWithCursor!T[][size_t] new_items;

    foreach (item; items.filter!"a.canAdvance".map!"a.advanced") {
      auto  term  = item.prev;
      const index = FindOrRegisterTermIndices(term);
      if (index !in new_items) {
        new_items[index] = [];
      }
      new_items[index] ~= item;
    }
    foreach (ref state; new_items) {
      state = Resolve(state).AttachFollowSet();
    }
    return new_items;
  }

  size_t[size_t][]     automaton;
  RuleWithCursor!T[][] states;

  const first_rule = rules.find!"a.lhs is b"(whole)[0];

  size_t current_state;
  states = [Resolve([RuleWithCursor!T(first_rule)]).AttachFollowSet()];

  while (true) {
    automaton.length = current_state+1;

    const advanced_states = Advance(states[current_state]);
    foreach (termi, state; advanced_states) {
      auto  index = states.countUntil!(x => x.equal(state));
      if (index < 0) {
        index   = states.length.to!(typeof(index));
        states ~= state.dup;
      }
      automaton[current_state][termi] = index.to!size_t;
    }
    if (++current_state >= states.length) break;
  }
  return ItemSet!T(whole, terms, automaton, states);
}

private RuleWithCursor!T[] AttachFollowSet(T)(RuleWithCursor!T[] rules) {
  alias TokenType = T.TokenType;

  TokenType[] CreateFollowSet(TypeInfo type, TypeInfo[] skip_types = []) {
    if (skip_types.canFind!"a is b"(type)) return [];

    auto result = appender!(TokenType[]);
    skip_types ~= type;

    foreach (const ref rule; rules) {
      if (rule.lhs is type) {
        result ~= rule.follows;
      }
      if (!rule.canAdvance || rule.next != type) continue;

      if (rule.cursor+1 < rule.rhs.length) {
        const follow_term = rule.rhs[rule.cursor+1];
        if (follow_term.isTerminal) {
          result ~= follow_term.terminalType;
        } else {
          result ~= rules.CreateFirstSet!TokenType(follow_term.nonTerminalType);
        }
      } else {
        result ~= CreateFollowSet(rule.lhs, skip_types);
      }
    }
    return result[];
  }

  TokenType[][TypeInfo] caches;

  RuleWithCursor!T[] result;
  foreach (const ref rule; rules) {
    if (rule.lhs !in caches) {
      caches[rule.lhs] = CreateFollowSet(rule.lhs).DropDuplicated;
    }
    result ~= RuleWithCursor!T(rule.entity, rule.cursor, caches[rule.lhs]);
  }
  return result;
}
