/// License: MIT
module sjplayer.Context;

import std.algorithm,
       std.array,
       std.typecons;

import sjscript;

import sjplayer.Background,
       sjplayer.ContextBuilderInterface,
       sjplayer.ElementDrawerInterface,
       sjplayer.ElementInterface,
       sjplayer.ProgramSet,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface;

///
class Context {
 public:
  ///
  this(ParametersBlock[] params, ProgramSet programs) {
    auto builder  = new Builder;
    auto varstore = new BlackHole!VarStoreInterface;

    background_ = new Background(programs.Get!BackgroundProgram);

    import sjplayer.BackgroundScheduledController,
           sjplayer.CircleElementScheduledController;
    auto factories = tuple(
        tuple(
          "background",
          BackgroundScheduledControllerFactory(varstore, background_),
        ),
        tuple(
          "circle",
          CircleElementScheduledControllerFactory(programs, varstore),
        ),
      );
    foreach (factory; factories) {
      factory[1].
        Create(params.filter!(x => x.name == factory[0]), builder);
    }

    elements_    = builder.elements[];
    drawers_     = builder.drawers[];
    controllers_ = builder.controllers[];
  }
  ///
  ~this() {
    controllers_.each!destroy;
    drawers_.each!destroy;
    elements_.each!destroy;

    background_.destroy();
  }

  ///
  ElementInterface.DamageCalculationResult CalculateDamage() const {
    assert(false);  // TODO:
  }
  ///
  void DrawBackground() {
    background_.Draw();
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
  class Builder : ContextBuilderInterface {
   public:
    override void AddElement(ElementInterface element) {
      elements ~= element;
    }
    override void AddElementDrawer(ElementDrawerInterface drawer) {
      drawers ~= drawer;
    }
    override void AddScheduledController(ScheduledControllerInterface controller) {
      controllers ~= controller;
    }
    Appender!(ElementInterface[])             elements;
    Appender!(ElementDrawerInterface[])       drawers;
    Appender!(ScheduledControllerInterface[]) controllers;
  }

  Background background_;

  ElementInterface[] elements_;

  ElementDrawerInterface[] drawers_;

  ScheduledControllerInterface[] controllers_;
}
