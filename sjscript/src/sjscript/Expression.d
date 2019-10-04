/// License: MIT
module sjscript.Expression;

import std.variant;

///
struct Expression {
 public:
  ///
  Expression opBinary(string op : "+")(Term rhs) {
    return Expression(terms ~ rhs);
  }
  ///
  Expression opBinary(string op : "-")(Term rhs) {
    return Expression(terms ~ rhs*(-1f));
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
  Term opBinary(string op : "*", T)(T rhs) {
    static if (is(T == Term)) {
      return Term(
          numerator   ~ rhs.numerator,
          denominator ~ rhs.denominator);
    } else {
      return Term(
          numerator ~ Value(rhs), denominator);
    }
  }
  ///
  Term opBinary(string op : "/", T)(T rhs) {
    static if (is(T == Term)) {
      return Term(
          numerator   ~ rhs.denominator,
          denominator ~ rhs.numerator);
    } else {
      return Term(
          numerator, denominator ~ Value(rhs));
    }
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
