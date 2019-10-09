/// License: MIT
module sjplayer.util.MatrixFactory;

import std.typecons;

import gl4d;

///
struct MatrixFactory {
 public:
  ///
  mat3 Create() const {
    auto m = mat3.identity;
    m.scale(scale.x, scale.y, scale.z);
    m.rotatex(rotation.x);
    m.rotatey(rotation.y);
    m.rotatez(rotation.z);
    m.translate(translation.x, translation.y, 1);
    return m;
  }

  ///
  Nullable!float GetValueByName(string name) const {
    switch (name) {
      case "scale_x":       return Nullable!float(scale.x);
      case "scale_y":       return Nullable!float(scale.y);
      case "rotation_x":    return Nullable!float(rotation.x);
      case "rotation_y":    return Nullable!float(rotation.y);
      case "rotation_z":    return Nullable!float(rotation.z);
      case "translation_x": return Nullable!float(translation.x);
      case "translation_y": return Nullable!float(translation.y);
      default: return Nullable!float.init;
    }
  }

  ///
  vec3 scale = vec3(1, 1, 1);
  ///
  vec3 rotation = vec3(0, 0, 0);
  ///
  vec2 translation = vec2(0, 0);
}
