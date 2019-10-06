/// License: MIT
module sjplayer.Context;

import std.algorithm;

import sjplayer.ElementInterface,
       sjplayer.ScheduledControllerInterface;

///
struct Context {
 public:
  @disable this();
  @disable this(this);

  ///
  ~this() {
    controllers_.each!destroy;
    drawers_.each!destroy;
    elements_.each!destroy;
  }

  ///
  ElementInterface.DamageCalculationResult CalculateDamage() const {
    assert(false);  // TODO:
  }

  ///
  void DrawElements() {
    drawers_.each!(x => x.Draw());
  }
  ///
  void OperateScheduledControllers(float time) {
    controllers_.each!(x => x.Operate(time));
  }

 private:
  ElementInterface[] elements_;

  ElementDrawerInterface[] drawers_;

  ScheduledControllerInterface[] controllers_;
}
