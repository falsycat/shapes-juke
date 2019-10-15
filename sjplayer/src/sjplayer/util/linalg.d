/// License: MIT
module sjplayer.util.linalg;

import std.algorithm;

import gl4d;

///
float CalculateDistanceOriginAndLineSegment(vec2 a, vec2 b) {
  const s     = b - a;
  const s_len = s.length;

  if (s_len == 0) return a.length;

  if (dot(a, s) * dot(b, s) < 0) {
    return cross(vec3(s, 0), vec3(a, 0)).length / s_len;
  }
  return min(a.length, b.length);
}
///
unittest {
  import std;
  assert(CalculateDistanceOriginAndLineSegment(
        vec2(0, 0), vec2(0, 0)).approxEqual(0f));

  assert(CalculateDistanceOriginAndLineSegment(
        vec2(-1, 1), vec2(1, 1)).approxEqual(1f));
  assert(CalculateDistanceOriginAndLineSegment(
        vec2(1, 1), vec2(2, 1)).approxEqual(sqrt(2f)));
  assert(CalculateDistanceOriginAndLineSegment(
        vec2(-2, 1), vec2(-1, 1)).approxEqual(sqrt(2f)));
}

///
float CalculateDistance2LineSegment(vec2 a1, vec2 b1, vec2 a2, vec2 b2) {
  if (a1 == b1) return CalculateDistanceOriginAndLineSegment(a2 - a1, b2 - a1);
  if (a2 == b2) return CalculateDistanceOriginAndLineSegment(a1 - a2, b1 - a2);

  const a1_to_b1 = b1 - a1;
  const a2_to_b2 = b2 - a2;

  if (cross2(a1_to_b1, a2_to_b2) == 0) {
    return CalculateDistanceOriginAndLineSegment(a2 - a1, b2 - a1);
  }

  const a1_to_a2 = a2 - a1;
  const a1_to_b2 = b2 - a1;
  const a2_to_a1 = a1 - a2;
  const a2_to_b1 = b1 - a2;

  if (cross2(a1_to_a2, a1_to_b1) * cross2(a1_to_b2, a1_to_b1) < 0 &&
      cross2(a2_to_a1, a2_to_b2) * cross2(a2_to_b1, a2_to_b2) < 0) {
    return 0;
  }

  const b1_to_a2 = a2 - b1;
  const b1_to_b2 = b2 - b1;
  return min(
      CalculateDistanceOriginAndLineSegment(a1_to_a2, a1_to_b2),
      CalculateDistanceOriginAndLineSegment(b1_to_a2, b1_to_b2)
    );
}
///
unittest {
  import std;
  assert(CalculateDistance2LineSegment(
        vec2(1, 0), vec2(1, 0), vec2(0, 1), vec2(0, -1)).approxEqual(1f));

  assert(CalculateDistance2LineSegment(
        vec2(-1, 0), vec2(1, 0), vec2(0, 1), vec2(0, -1)).approxEqual(0f));
  assert(CalculateDistance2LineSegment(
        vec2(-1, 0), vec2(1, 0), vec2(1, 1), vec2(1, -1)).approxEqual(0f));
  assert(CalculateDistance2LineSegment(
        vec2(-1, 0), vec2(1, 0), vec2(2, 1), vec2(2, -1)).approxEqual(1f));
}

///
float cross2(vec2 v1, vec2 v2) {
  return v1.x * v2.y - v1.y * v2.x;
}
