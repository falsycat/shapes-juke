/// License: MIT
module sjplayer.AbstractShapeElement;

import gl4d;

import sjplayer.ElementInterface,
       sjplayer.ShapeElementProgram;

///
abstract class AbstractShapeElement : ElementInterface {
 public:
  ///
  void Initialize() {
    alive        = false;
    damage       = 0;
    nearness_coe = 0;
    instance     = instance.init;
  }

  abstract override DamageCalculationResult CalculateDamage(vec2 p1, vec2 p2) const;

  ///
  bool alive;
  ///
  float damage;
  ///
  float nearness_coe;
  ///
  ShapeElementProgramInstance instance;
  alias instance this;
}
