/// License: MIT
module sjplayer.CircleElement;

import std.algorithm,
       std.math;

import gl4d;

import sjplayer.ElementDrawer,
       sjplayer.ElementInterface,
       sjplayer.ShapeElementProgram,
       sjplayer.util.linalg;

///
class CircleElement : ElementInterface {
 public:
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
    const d = CalculateDistanceOriginAndLineSegment(a, b);

    if (d <= 1) {
      return DamageCalculationResult(damage, 0);
    }
    return DamageCalculationResult(0, 1 - (d-1).clamp(0, 1));
  }

  ///
  bool alive;
  ///
  float damage;
  ///
  float nearness_coe;
  ///
  CircleElementProgram.Instance instance;
  alias instance this;
}

///
alias CircleElementDrawer = ElementDrawer!(
    CircleElementProgram,
    CircleElement,
    [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1)]);

///
alias CircleElementProgram = ShapeElementProgram!(q{
    float r = length(uv_);
    float w = 1 - weight_;
    return
      smoothstep(w-smooth_, w, r) *
      (1 - smoothstep(1-smooth_, 1, r));
  });
