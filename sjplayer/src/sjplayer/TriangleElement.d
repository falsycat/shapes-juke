/// License: MIT
module sjplayer.TriangleElement;

import std.algorithm,
       std.math,
       std.typecons;

import gl4d;

import sjplayer.AbstractShapeElement,
       sjplayer.ElementInterface,
       sjplayer.ShapeElementDrawer,
       sjplayer.ShapeElementProgram,
       sjplayer.ShapeElementScheduledController,
       sjplayer.util.linalg;

///
class TriangleElement : AbstractShapeElement {
 public:
  override DamageCalculationResult CalculateDamage(vec2 p1, vec2 p2) const {
    if (!alive) return DamageCalculationResult(0, 0);

    const m = matrix.inverse;
    const a = (m * vec3(p1, 1)).xy;
    const b = (m * vec3(p2, 1)).xy;

    enum A = vec2( 0,  sqrt(3f)*2f/3f);
    enum B = vec2(-1, -sqrt(3f)   /3f);
    enum C = vec2( 1, -sqrt(3f)   /3f);

    bool CheckInside(vec2 pt) {
      return
        cross2(B-A, pt-A) >= 0 && cross2(pt-A, C-A) >= 0 && cross2(C-B, pt-B) >= 0;
    }
    if (CheckInside(a) || CheckInside(b)) {
      return DamageCalculationResult(damage, 0);
    }

    enum edges = [
      tuple(A, B),
      tuple(A, C),
      tuple(B, C),
    ];
    float[3] distances;
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
alias TriangleElementDrawer = ShapeElementDrawer!(
    TriangleElementProgram,
    [vec2(-1, 1.2), vec2(-1, -1), vec2(1, -1), vec2(1, 1.2)]);

///
alias TriangleElementProgram = ShapeElementProgram!(q{
    vec2 A = vec2( 0,  sqrt(3)*2/3);
    vec2 B = vec2(-1, -sqrt(3)  /3);
    vec2 C = vec2( 1, -sqrt(3)  /3);

    vec2 AB = B - A;
    vec2 AC = C - A;
    vec2 BC = C - B;

    float cross_AB = AB.x * (uv_.y - A.y) - AB.y * (uv_.x - A.x);
    float cross_AC = (uv_.x - A.x) * AC.y - (uv_.y - A.y) * AC.x;
    float cross_BC = BC.x * (uv_.y - B.y) - BC.y * (uv_.x - B.x);

    return step(0, cross_AB) * step(0, cross_AC) * step(0, cross_BC);
  });

///
alias TriangleElementScheduledControllerFactory =
  ShapeElementScheduledControllerFactory!(
      TriangleElement,
      TriangleElementDrawer);
