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
  enum AccelAdjustment = 0.005;
  ///
  enum MaxSpeed = 0.03;
  ///
  enum SpeedAttenuation = 0.08;

  ///
  this(
      Actor actor,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(actor, varstore, operations);
    actor_      = actor;
    varstore_   = varstore;
    operations_ = operations;

    accel_ = vec2(0, 0);
  }

  override void Accelarate(vec2 accel) {
    accel_ = accel * AccelAdjustment;
  }
  override void Update() {
    actor_.speed += accel_;

    const speed_length = actor_.speed.length;
    if (speed_length > MaxSpeed) {
      actor_.speed = actor_.speed / speed_length * MaxSpeed;
    }

    actor_.pos += actor_.speed;

    const left_edge   = -1 + actor_.clip_lefttop.x;
    const right_edge  = 1 - actor_.clip_rightbottom.x;
    const top_edge    = 1 - actor_.clip_lefttop.y;
    const bottom_edge = -1 + actor_.clip_rightbottom.y;
    actor_.pos.x = actor_.pos.x.clamp(left_edge, right_edge);
    actor_.pos.y = actor_.pos.y.clamp(bottom_edge, top_edge);

    actor_.speed *= 1-SpeedAttenuation;
  }

 private:
  Actor actor_;

  const VarStoreInterface varstore_;

  const ParametersBlock[] operations_;

  vec2 accel_;
}

private alias ActorScheduledController = ScheduledController!(
    Actor,
    [
      "color_r": "color.r",
      "color_g": "color.g",
      "color_b": "color.b",
      "color_a": "color.a",

      "clip_left":   "clip_lefttop.x",
      "clip_top":    "clip_lefttop.y",
      "clip_right":  "clip_rightbottom.x",
      "clip_bottom": "clip_rightbottom.y",
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
  @property ActorController product() out (r; r) {
    return product_;
  }

 private:
  const VarStoreInterface varstore_;

  Actor actor_;

  ActorController product_;
}
