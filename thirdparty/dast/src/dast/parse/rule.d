/// License: MIT
module dast.parse.rule;

import std.algorithm,
       std.array,
       std.traits;

import dast.tokenize;

///
unittest {
  enum TokenType {
    Number,
  }
  alias Token = dast.tokenize.Token!(TokenType, string);

  struct RuleSet {
   public:
    int ParseWhole(@(TokenType.Number) Token, string v) {
      assert(false);
    }
  }
  enum rule_ctfe = Rule!TokenType.CreateFromNonOverloadedMethod!(RuleSet, "ParseWhole");

  static assert(rule_ctfe.lhs is typeid(int));

  static assert(rule_ctfe.rhs.length == 2);
  static assert(rule_ctfe.rhs[0] == TokenType.Number);
  static assert(rule_ctfe.rhs[1] == typeid(string));
}

///
template IsRule(T) {
  static if (__traits(compiles, T.TokenType)) {
    enum IsRule = is(T : Rule!(T.TokenType));
  } else {
    enum IsRule = false;
  }
}

///
struct NamedRule(TokenType) if (is(TokenType == enum)) {
 public:
  alias entity this;

  ///
  const string name;
  ///
  const Rule!TokenType entity;
}

///
struct Rule(TokenType_) if (is(TokenType_ == enum)) {
 public:
  ///
  alias TokenType = TokenType_;

  ///
  static Rule CreateFromNonOverloadedMethod(T, string name)()
      if (__traits(hasMember, T, name)) {
    alias method = mixin("T." ~ name);
    alias Params = Parameters!method;

    auto rhs = appender!(Term!TokenType[])();
    static foreach (parami; 0..Params.length) {
      static if (IsToken!(Params[parami])) {{
        static foreach (attr; __traits(getAttributes, Params[parami..parami+1])) {
          static if (is(typeof(attr) == TokenType)) {
            static assert(!__traits(compiles, found_attr));
            enum found_attr = true;
            rhs ~= Term!TokenType(attr);
          }
        }
        static assert(__traits(compiles, found_attr));
      }} else {
        rhs ~= Term!TokenType(TypeInfoWithSize.CreateFromType!(Params[parami]));
      }
    }
    return Rule(typeid(ReturnType!method), rhs.array);
  }

  ///
  bool opEquals(Rule other) const {
    return lhs is other.lhs && rhs_.equal(other.rhs_);
  }

  ///
  @property TypeInfo lhs() const {
    return cast(TypeInfo) lhs_;
  }
  ///
  @property const(Term!TokenType[]) rhs() const {
    return rhs_;
  }

 private:
  const TypeInfo lhs_;
  invariant(lhs_ !is null);

  const Term!TokenType[] rhs_;
  invariant(rhs_.length > 0);
}

///
struct Term(TokenType) if (is(TokenType == enum)) {
 public:
  @disable this();

  ///
  this(TypeInfoWithSize type) {
    data_.type_info = type;
    terminal_       = false;
  }
  ///
  this(TokenType type) {
    data_.token_type = type;
    terminal_        = true;
  }

  ///
  bool opEquals(in Term rhs) const {
    return isTerminal?
      rhs.isTerminal  && terminalType    == rhs.terminalType:
      !rhs.isTerminal && nonTerminalType is rhs.nonTerminalType;
  }
  ///
  bool opEquals(in TypeInfo type) const {
    return !isTerminal && nonTerminalType is type;
  }
  ///
  bool opEquals(TokenType type) const {
    return isTerminal && terminalType == type;
  }

  ///
  @property bool isTerminal() const {
    return terminal_;
  }

  ///
  @property TokenType terminalType() const in (isTerminal) {
    return data_.token_type;
  }
  ///
  @property TypeInfoWithSize nonTerminalType() const in (!isTerminal) {
    return cast(TypeInfoWithSize) data_.type_info;
  }

 private:
  union Data {
    TypeInfoWithSize type_info;
    TokenType        token_type;
  }
  Data data_;
  bool terminal_;
}

///
struct TypeInfoWithSize {
 public:
  alias entity this;

  ///
  static TypeInfoWithSize CreateFromType(T)() {
    return TypeInfoWithSize(T.sizeof, typeid(T));
  }

  ///
  const size_t tsize;
  ///
  TypeInfo entity;
}
