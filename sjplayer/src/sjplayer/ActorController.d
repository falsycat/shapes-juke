/// License: MIT
module sjplayer.ActorController;

import std.algorithm;

import gl4d;

import sjscript;

import sjplayer.Actor,
       sjplayer.ScheduledController,
       sjplayer.VarStoreInterface;

///
class ActorController : ActorScheduledController {
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

  ///
  void Manipulate(vec2 accel) {
    actor_.accel += accel;

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
