/// License: MIT
module gl4d.util.ProjectionMatrixFactory;

import gl3n.linalg;

///
struct ProjectionMatrixFactory {
 public:
  ///
  mat4 Create() const {
    return mat4.perspective(aspect, 1, fov, near, far);
  }

  ///
  float aspect = 1;
  ///
  float fov = 60;
  ///
  float far = 100;
  ///
  float near = 0.1;
}
