/// License: MIT
module sjplayer.PostEffectController;

import std.range.primitives;

import sjscript;

import sjplayer.AbstractScheduledController,
       sjplayer.ContextBuilderInterface,
       sjplayer.PostEffect,
       sjplayer.PostEffectControllerInterface,
       sjplayer.ScheduledController,
       sjplayer.VarStoreInterface;

///
class PostEffectController : PostEffectScheduledController, PostEffectControllerInterface {
 public:
  ///
  this(
      PostEffect posteffect,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(posteffect, varstore, operations);
    posteffect_ = posteffect;
  }

  override void CauseDamagedEffect() {
  }
  override void Update() {
  }

 private:
  PostEffect posteffect_;
}

private alias PostEffectScheduledController = ScheduledController!(
    PostEffect,
    [
      "clip_left":   "clip_lefttop.x",
      "clip_top":    "clip_lefttop.y",
      "clip_right":  "clip_rightbottom.x",
      "clip_bottom": "clip_rightbottom.y",
    ]
  );

///
struct PostEffectControllerFactory {
 public:
  ///
  this(in VarStoreInterface varstore, PostEffect posteffect) {
    varstore_   = varstore;
    posteffect_ = posteffect;
  }

  ///
  void Create(R)(R params, ContextBuilderInterface builder)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    product_ = new PostEffectController(
        posteffect_, varstore_, SortParametersBlock(params));
    builder.AddScheduledController(product_);
  }

  ///
  @property PostEffectController product() out (r; r) {
    return product_;
  }

 private:
  const VarStoreInterface varstore_;

  PostEffect posteffect_;

  PostEffectController product_;
}
