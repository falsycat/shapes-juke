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
  float start;

  ///
  float end;
}

///
enum ParameterType {
  Assign,
  AddAssign,
  OnceAssign,
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
