/// License: MIT
module sjplayer.ActorController;

import std.algorithm,
       std.range.primitives;

import gl4d;

import sjscript;

import sjplayer.AbstractScheduledController,
       sjplayer.Actor,
       sjplayer.ActorControllerInterface,
       sjplayer.ContextBuilderInterface,
       sjplayer.ScheduledController,
       sjplayer.VarStoreInterface;

///
class ActorController : ActorScheduledController, ActorControllerInterface {
 public:
  ///
  enum MaxAccel = 1e-1;

  ///
  this(
      Actor actor,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(actor, varstore, operations);
    actor_      = actor;
    varstore_   = varstore;
    operations_ = operations;
  }

  override void Accelarate(vec2 accel) {
    actor_.accel += accel;
  }
  override void Update() {
    actor_.accel.x = actor_.accel.x.clamp(-MaxAccel, MaxAccel);
    actor_.accel.y = actor_.accel.y.clamp(-MaxAccel, MaxAccel);

    actor_.pos += actor_.accel;
    // TODO: clamping the actor position
  }

 private:
  Actor actor_;

  const VarStoreInterface varstore_;

  const ParametersBlock[] operations_;
}

private alias ActorScheduledController = ScheduledController!(
    Actor,
    [
      "color_r": "color.r",
      "color_g": "color.g",
      "color_b": "color.b",
      "color_a": "color.a",
    ]
  );

///
struct ActorControllerFactory {
 public:
  ///
  this(in VarStoreInterface varstore, Actor actor) {
    varstore_ = varstore;
    actor_    = actor;
  }

  ///
  void Create(R)(R params, ContextBuilderInterface builder)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    product_ = new ActorController(
        actor_, varstore_, SortParametersBlock(params));
    builder.AddScheduledController(product_);
  }

  ///
  @property ActorController product() {
    return product_;
  }

 private:
  const VarStoreInterface varstore_;

  Actor actor_;

  ActorController product_;
}
