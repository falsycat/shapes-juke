/// License: MIT
module gl4d.util.ModelMatrixFactory;

import gl3n.linalg;

///
struct ModelMatrixFactory(size_t dim) if (dim == 3 || dim == 4) {
 public:
  ///
  alias mat = Matrix!(float, dim, dim);

  ///
  mat Create() const {
    auto m = mat.identity;
    static if (dim == 3) {
      m.scale(scale.x, scale.y, 1);
      m.rotatex(rotation.x);
      m.rotatey(rotation.y);
      m.rotatez(rotation.z);
      m.translate(translation.x, translation.y, 1);

    } else static if (dim == 4) {
      m.scale(scale.x, scale.y, scale.z);
      m.rotatex(rotation.x);
      m.rotatey(rotation.y);
      m.rotatez(rotation.z);
      m.translate(translation.x, translation.y, translation.z);
    }
    return m;
  }

  static if (dim == 3) {
    ///
    vec2 scale       = vec2(1, 1);
    ///
    vec3 rotation    = vec3(0, 0, 0);
    ///
    vec2 translation = vec2(0, 0);

  } else static if (dim == 4) {
    ///
    vec3 scale       = vec3(1, 1, 1);
    ///
    vec3 rotation    = vec3(0, 0, 0);
    ///
    vec3 translation = vec3(0, 0, 0);
  }
}
static assert(__traits(compiles, ModelMatrixFactory!3));
static assert(__traits(compiles, ModelMatrixFactory!4));
