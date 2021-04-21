/// License: MIT
module gl4d.util.ViewMatrixFactory;

import gl3n.linalg;

///
struct ViewMatrixFactory {
 public:
  ///
  mat4 Create() const {
    return mat4.look_at(pos, target, up);
  }

  ///
  vec3 pos = vec3(0, -1, 0);
  ///
  vec3 target = vec3(0, 0, 0);
  ///
  vec3 up = vec3(0, 1, 0);
}
