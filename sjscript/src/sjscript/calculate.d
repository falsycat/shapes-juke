/// License: MIT
module sjscript.calculate;

import std.algorithm,
       std.array,
       std.exception,
       std.format,
       std.math,
       std.traits,
       std.variant;

import sjscript.Expression,
       sjscript.func;

///
enum IsVarStore(T) =
  is(typeof((T vars, string name) => vars[name])) &&
  is(ReturnType!((T vars, string name) => vars[name]) == float);
static assert(IsVarStore!(float[string]));

///
struct NullVarStore {
 public:
  static float opIndex(string name) {
    // TODO: error handling
    throw new Exception("undefined variable %s".format(name));
  }
  static assert(IsVarStore!NullVarStore);
}

///
float CalculateExpression(VarStore)(in Expression expr, VarStore vars)
    if (IsVarStore!VarStore) {
  return expr.terms.map!(x => x.CalculateTerm(vars)).sum;
}

///
float CalculateTerm(VarStore)(in Term term, VarStore vars)
    if (IsVarStore!VarStore) {
  auto num = 1f, den = 1f;
  term.numerator.
    map!(x => x.CalculateTermValue(vars)).
    each!(x => num *= x);
  term.denominator.
    map!(x => x.CalculateTermValue(vars)).
    each!(x => den *= x);
  (!den.approxEqual(0)).enforce();
  return num / den;
}

///
float CalculateTermValue(VarStore)(in Term.Value value, VarStore vars)
    if (IsVarStore!VarStore) {
  return value.visit!(
      (string name)          => vars[name],
      (float  val)           => val,
      (in FunctionCall func) => func.CalculateFunction(vars),
      (in Expression expr)   => expr.CalculateExpression(vars));
}

///
float CalculateFunction(VarStore)(in FunctionCall fcall, VarStore vars)
    if (IsVarStore!VarStore) {
  return fcall.name.CallFunction(
      fcall.args.map!(x => x.CalculateExpression(vars)).array);
}
