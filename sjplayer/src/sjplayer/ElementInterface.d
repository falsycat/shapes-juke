/// License: MIT
module sjplayer.ElementInterface;

import gl4d;

///
interface ElementInterface {
 public:
  ///
  static struct DamageCalculationResult {
    /// An amount of the damage. (0~1)
    float damage;
    /// A nearness of the point. (0~1)
    float nearness;
  }

  ///
  DamageCalculationResult CalculateDamage(vec2 p1, vec2 p2) const;
}
