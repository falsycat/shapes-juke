/// License: MIT
///
/// Types declared in this file are not considered at copying because of processing speed.
/// So you should add a const qual when use them after parsing.
///
module sjscript.Expression;

import std.algorithm,
       std.meta,
       std.variant;

///
struct Expression {
 public:
  ///
  Expression opBinary(string op)(Term rhs) if (op == "+" || op == "-") {
    static if (op == "-") {
      rhs = rhs * -1f;
    }
    return Expression(terms ~ rhs);
  }

  ///
  Term[] terms;
}

///
struct Term {
 public:
  ///
  alias Value = Algebraic!(float, string, FunctionCall, Expression);

  ///
  Term opBinary(string op, T)(T rhs) if ((op == "*" || op == "/")) {
    static if (is(T == Term)) {
      auto rnumerator   = rhs.numerator;
      auto rdenominator = rhs.denominator;
    } else static if (staticIndexOf!(T, Value.AllowedTypes) >= 0) {
      auto    rnumerator = [Value(rhs)];
      Value[] rdenominator;
    } else {
      static assert(false);
    }
    static if (op == "/") swap(rnumerator, rdenominator);

    return Term(numerator ~ rnumerator, denominator ~ rdenominator);
  }

  ///
  Value[] numerator;
  ///
  Value[] denominator;
}

///
struct FunctionCall {
 public:
  ///
  string name;
  ///
  Expression[] args;
}
