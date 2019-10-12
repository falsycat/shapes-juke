/// License: MIT
module sjplayer.util.Parameter;

import std.typecons;

import gl4d;

import sjscript;

///
void CalculateParameter(T)(
    in Parameter param, ref float value, T vars) {
  auto result = param.rhs.CalculateExpression(vars);
  if (param.type == ParameterType.AddAssign) result += value;
  value = result;
}

///
bool CalculateModelMatrixParameter(T)(
    in Parameter param, ref ModelMatrixFactory!3 m, T vars) {
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

///
Nullable!float GetModelMatrixParameterValueByName(
    ref in ModelMatrixFactory!3 m, string name) {
  switch (name) {
    case "scale_x":       return Nullable!float(m.scale.x);
    case "scale_y":       return Nullable!float(m.scale.y);
    case "rotation_x":    return Nullable!float(m.rotation.x);
    case "rotation_y":    return Nullable!float(m.rotation.y);
    case "rotation_z":    return Nullable!float(m.rotation.z);
    case "translation_x": return Nullable!float(m.translation.x);
    case "translation_y": return Nullable!float(m.translation.y);
    default: return Nullable!float.init;
  }
}
