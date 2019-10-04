/// License: MIT
module sjscript.Expression;

import std.variant;

///
struct Expression {
 public:
  ///
  Term opBinary(string op : "+", T)(T rhs) const {
    return Expression(terms ~ rhs);
  }
  ///
  Term opBinary(string op : "-", T)(T rhs) const {
    return Expression(terms ~ rhs*(-1f));
  }

  ///
  Term[] terms;
}

///
struct Term {
 public:
  ///
  alias Value = Algebraic!(float, string, FunctionCall);

  ///
  Term opBinary(string op : "*", T)(T rhs) const {
    return Term(multipled_values ~ Value(rhs), divided_values);
  }
  ///
  Term opBinary(string op : "/", T)(T rhs) const {
    return Term(multipled_values, divided_values ~ Value(rhs));
  }

  ///
  Value[] multipled_values;
  ///
  Value[] divided_values;
}

///
struct FunctionCall {
 public:
  ///
  string name;

  ///
  Expression[] args;
}
