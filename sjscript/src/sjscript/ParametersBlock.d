/// License: MIT
module sjscript.ParametersBlock;

import sjscript.Expression,
       sjscript.Token;

///
struct ParametersBlock {
 public:
  ///
  string name;

  ///
  Period period;

  ///
  Parameter[] parameters;

  ///
  TokenPos pos;
}

///
struct Period {
 public:
  ///
  size_t start;

  ///
  size_t end;
}

///
enum ParameterType {
  Assign,
  AddAssign,
}

///
struct Parameter {
 public:
  ///
  string name;

  ///
  ParameterType type;

  ///
  Expression rhs;

  ///
  TokenPos pos;
}
