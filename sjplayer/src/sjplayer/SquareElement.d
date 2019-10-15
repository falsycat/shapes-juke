/// License: MIT
module sjplayer.SquareElement;

import std.algorithm,
       std.typecons;

import gl4d;

import sjplayer.ElementDrawer,
       sjplayer.ElementInterface,
       sjplayer.ShapeElementProgram,
       sjplayer.util.linalg;

///
class SquareElement : ElementInterface {
 public:
  ///
  static struct Instance {
    ///
    align(1) mat3 matrix = mat3.identity;
    ///
    align(1) float weight = 1;
    ///
    align(1) float smooth = 0.001;
    ///
    align(1) vec4 color = vec4(0, 0, 0, 0);
  }

  ///
  void Initialize() {
    alive        = false;
    damage       = 0;
    nearness_coe = 0;
    instance     = instance.init;
  }

  override DamageCalculationResult CalculateDamage(vec2 p1, vec2 p2) const {
    if (!alive) return DamageCalculationResult(0, 0);

    const m = matrix.inverse;
    const a = (m * vec3(p1, 1)).xy;
    const b = (m * vec3(p2, 1)).xy;

    if ((-1 <= a.x && a.x <= 1 && -1 <= a.y && a.y <= 1) ||
        (-1 <= b.x && b.x <= 1 && -1 <= b.y && b.y <= 1)) {
      return DamageCalculationResult(damage, 0);
    }

    enum edges = [
      tuple(vec2(-1,  1), vec2(-1, -1)),
      tuple(vec2(-1, -1), vec2( 1, -1)),
      tuple(vec2( 1, -1), vec2( 1,  1)),
      tuple(vec2( 1,  1), vec2(-1,  1)),
    ];
    float[4] distances;
    static foreach (i, edge; edges) {
      distances[i] = CalculateDistance2LineSegment(edge[0], edge[1], a, b);
    }
    const min_distance = distances[].minElement;

    if (min_distance == 0) {
      return DamageCalculationResult(damage, 0);
    }
    return DamageCalculationResult(0, 1-(min_distance-1).clamp(0f, 1f));
  }

  ///
  bool alive;
  ///
  float damage;
  ///
  float nearness_coe;
  ///
  Instance instance;
  alias instance this;
}

///
alias SquareElementDrawer = ElementDrawer!(
    SquareElementProgram,
    SquareElement,
    [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1)]);

///
alias SquareElementProgram = ShapeElementProgram!(q{
    float w = 1-weight_;
    float s = smooth_;
    return clamp(
        smoothstep(w-s, w, abs(uv_.x)) +
        smoothstep(w-s, w, abs(uv_.y)), 0, 1);
  });
