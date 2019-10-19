/// License: MIT
module sjplayer.SquareElement;

import std.algorithm,
       std.typecons;

import gl4d;

import sjplayer.AbstractShapeElement,
       sjplayer.ElementInterface,
       sjplayer.ShapeElementDrawer,
       sjplayer.ShapeElementScheduledController,
       sjplayer.ShapeElementProgram,
       sjplayer.util.linalg;

///
class SquareElement : AbstractShapeElement {
 public:
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
    const nearness = 1 - (min_distance-1).clamp(0f, 1f);
    return DamageCalculationResult(0, nearness * nearness_coe);
  }
}

///
alias SquareElementDrawer = ShapeElementDrawer!(
    SquareElementProgram,
    [vec2(-1, 1), vec2(1, 1), vec2(1, -1), vec2(-1, -1)]);

///
alias SquareElementProgram = ShapeElementProgram!(q{
    float w = 1-weight_;
    float s = smooth_;
    return clamp(
        smoothstep(w-s, w, abs(uv_.x))*(1-smoothstep(1-s, 1, abs(uv_.x))) +
        smoothstep(w-s, w, abs(uv_.y))*(1-smoothstep(1-s, 1, abs(uv_.y))), 0, 1);
  });

///
alias SquareElementScheduledControllerFactory =
  ShapeElementScheduledControllerFactory!(
      SquareElement,
      SquareElementDrawer);
