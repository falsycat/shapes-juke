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
