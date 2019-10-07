/// License: MIT
module sjplayer.util.Parameter;

import sjscript;

import sjplayer.util.MatrixFactory;

///
void CalculateParameter(T)(
    in Parameter param, ref float value, T vars) {
  auto result = param.rhs.CalculateExpression(vars);
  if (param.type == ParameterType.AddAssign) result += value;
  value = result;
}

///
bool CalculateMatrixParameter(T)(
    in Parameter param, ref MatrixFactory m, T vars) {
  switch (param.name) {
    case "translation_x":
      param.CalculateParameter(m.translation.x, vars);
      return true;
    case "translation_y":
      param.CalculateParameter(m.translation.y, vars);
      return true;

    case "rotation_x":
      param.CalculateParameter(m.rotation.x, vars);
      return true;
    case "rotation_y":
      param.CalculateParameter(m.rotation.y, vars);
      return true;
    case "rotation_z":
      param.CalculateParameter(m.rotation.z, vars);
      return true;

    case "scale_x":
      param.CalculateParameter(m.scale.x, vars);
      return true;
    case "scale_y":
      param.CalculateParameter(m.scale.y, vars);
      return true;

    default: return false;
  }
}
