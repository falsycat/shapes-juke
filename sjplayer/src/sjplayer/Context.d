/// License: MIT
module sjplayer.Context;

import std.algorithm,
       std.typecons;

import sjscript;

import sjplayer.ElementInterface,
       sjplayer.ElementProgramSet,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface;

///
struct Context {
 public:
  @disable this();
  @disable this(this);

  ///
  this(ParametersBlock[] params, ElementProgramSet programs) {
    auto varstore = new BlackHole!VarStoreInterface;

    import sjplayer.CircleElementScheduledController;
    auto factories = tuple(
        tuple(
          "circle",
          CircleElementScheduledControllerFactory(programs, varstore),
        ),
      );
    foreach (factory; factories) {
      auto result = factory[1].
        Create(params.filter!(x => x.name == factory[0]));
      elements_    ~= result.elements;
      drawers_     ~= result.drawer;
      controllers_ ~= result.controllers;
    }
  }
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
