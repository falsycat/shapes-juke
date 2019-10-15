/// License: MIT
module sjplayer.Context;

import std.algorithm,
       std.array,
       std.typecons;

import gl4d;

import sjscript;

import sjplayer.Actor,
       sjplayer.ActorController,
       sjplayer.ActorControllerInterface,
       sjplayer.Background,
       sjplayer.ContextBuilderInterface,
       sjplayer.ElementDrawerInterface,
       sjplayer.ElementInterface,
       sjplayer.PostEffect,
       sjplayer.PostEffectController,
       sjplayer.PostEffectControllerInterface,
       sjplayer.ProgramSet,
       sjplayer.ScheduledControllerInterface,
       sjplayer.SquareElementScheduledController,
       sjplayer.VarStore,
       sjplayer.VarStoreScheduledController;

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
          "posteffect",
          PostEffectControllerFactory(varstore, posteffect_),
        ),

        tuple(
          "background",
          BackgroundScheduledControllerFactory(varstore, background_),
        ),
        tuple(
          "circle",
          CircleElementScheduledControllerFactory(programs, varstore),
        ),
        tuple(
          "square",
          SquareElementScheduledControllerFactory(programs, varstore),
        ),
        tuple(
          "variable",
          VarStoreScheduledControllerFactory(varstore),
        ),
      );
    foreach (ref factory; factories) {
      factory[1].
        Create(params.filter!(x => x.name == factory[0]), builder);
    }

    length_ = 0;
    foreach (ref param; params) {
      length_ = length_.max(param.period.end);
    }

    elements_    = builder.elements[];
    drawers_     = builder.drawers[];
    controllers_ = builder.controllers[];

    actor_controller_      = factories[0][1].product;
    posteffect_controller_ = factories[1][1].product;
  }
  ///
  ~this() {
    controllers_.each!destroy;
    drawers_.each!destroy;
    elements_.each!destroy;

    posteffect_.destroy();
    background_.destroy();
    actor_.destroy();
  }

  ///
  ElementInterface.DamageCalculationResult CalculateDamage() const {
    auto result = ElementInterface.DamageCalculationResult(0, 0);
    elements_.
      map!(x => x.CalculateDamage(actor_.pos, actor_.pos - actor_.speed)).
      each!((x) {
          result.damage   += x.damage;
          result.nearness += x.nearness;
        });
    return result;
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
  ///
  void EndDrawing() {
    posteffect_.UnbindFramebuffer();
    posteffect_.DrawFramebuffer();
  }

  ///
  @property inout(ActorControllerInterface) actor() inout {
    return actor_controller_;
  }
  ///
  @property inout(PostEffectControllerInterface) posteffect() inout {
    return posteffect_controller_;
  }
  ///
  @property float length() const {
    return length_;
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

  Actor      actor_;
  Background background_;
  PostEffect posteffect_;

  ElementInterface[]             elements_;
  ElementDrawerInterface[]       drawers_;
  ScheduledControllerInterface[] controllers_;

  ActorControllerInterface      actor_controller_;
  PostEffectControllerInterface posteffect_controller_;

  float length_;
}
