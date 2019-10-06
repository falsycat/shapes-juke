/// License: MIT
module sjplayer.util.Parameter;

import sjscript;

///
void CalculateParameter(T)(
    ref float value, in Parameter param, T vars) {
  auto result = param.rhs.CalculateExpression(vars);
  if (param.type == ParameterType.AddAssign) result += value;
  value = result;
}
