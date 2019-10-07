/// License: MIT
module sjplayer.util.MatrixFactory;

import gl4d;

///
struct MatrixFactory {
 public:
  ///
  @property mat3 Create() const {
    auto m = mat3.identity;
    m.scale(scale.x, scale.y, scale.z);
    m.rotatex(rotation.x);
    m.rotatey(rotation.y);
    m.rotatez(rotation.z);
    m.translate(translation.x, translation.y, translation.z);
    return m;
  }

  ///
  vec3 scale = vec3(1, 1, 1);
  ///
  vec3 rotation = vec3(0, 0, 0);
  ///
  vec3 translation = vec3(0, 0, 0);
}
