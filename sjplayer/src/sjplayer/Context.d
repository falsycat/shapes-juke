/// License: MIT
module sjplayer.Context;

import std.algorithm,
       std.array,
       std.typecons;

import gl4d;

import sjscript;

import sjplayer.Actor,
       sjplayer.ActorController,
       sjplayer.Background,
       sjplayer.ContextBuilderInterface,
       sjplayer.ElementDrawerInterface,
       sjplayer.ElementInterface,
       sjplayer.PostEffect,
       sjplayer.ProgramSet,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStore;

///
class Context {
 public:
  ///
  this(ParametersBlock[] params, vec2i window_size, ProgramSet programs) {
    actor_      = new Actor(programs.Get!ActorProgram);
    background_ = new Background(programs.Get!BackgroundProgram);
    posteffect_ = new PostEffect(programs.Get!PostEffectProgram, window_size);

    auto builder  = new Builder;
    auto varstore = new VarStore(actor_);

    import sjplayer.BackgroundScheduledController,
           sjplayer.CircleElementScheduledController;
    auto factories = tuple(
        tuple(
          "actor",
          ActorControllerFactory(varstore, actor_),
        ),
        tuple(
          "background",
          BackgroundScheduledControllerFactory(varstore, background_),
        ),
        tuple(
          "circle",
          CircleElementScheduledControllerFactory(programs, varstore),
        ),
      );
    foreach (ref factory; factories) {
      factory[1].
        Create(params.filter!(x => x.name == factory[0]), builder);
    }

    elements_    = builder.elements[];
    drawers_     = builder.drawers[];
    controllers_ = builder.controllers[];

    actor_controller_ = factories[0][1].product;
  }
  ///
  ~this() {
    controllers_.each!destroy;
    actor_controller_.destroy();

    drawers_.each!destroy;
    elements_.each!destroy;

    actor_.destroy();
    background_.destroy();
    posteffect_.destroy();
  }

  ///
  ElementInterface.DamageCalculationResult CalculateDamage() const {
    assert(false);  // TODO:
  }

  ///
  void UpdateActor(vec2 accel) {
    actor_controller_.Update(accel);
  }
  ///
  void OperateScheduledControllers(float time) {
    controllers_.each!(x => x.Operate(time));
  }

  ///
  void StartDrawing() {
    posteffect_.BindFramebuffer();
  }
  ///
  void EndDrawing() {
    posteffect_.UnbindFramebuffer();
    posteffect_.DrawFramebuffer();
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
  void DrawActor() {
    actor_.Draw();
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

  Actor actor_;
  invariant(actor_);

  ActorController actor_controller_;
  invariant(actor_controller_);

  Background background_;
  invariant(background_);

  PostEffect posteffect_;
  invariant(posteffect_);

  ElementInterface[] elements_;

  ElementDrawerInterface[] drawers_;

  ScheduledControllerInterface[] controllers_;
}
