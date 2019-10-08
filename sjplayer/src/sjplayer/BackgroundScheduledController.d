/// License: MIT
module sjplayer.BackgroundScheduledController;

import std.algorithm,
       std.array,
       std.exception,
       std.range.primitives;

import sjscript;

import sjplayer.AbstractScheduledController,
       sjplayer.Background,
       sjplayer.ContextBuilderInterface,
       sjplayer.ScheduledController,
       sjplayer.VarStoreInterface,
       sjplayer.util.Period;

///
alias BackgroundScheduledController = ScheduledController!(
    Background,
    [
      "inner_r": "inner_color.r",
      "inner_g": "inner_color.g",
      "inner_b": "inner_color.b",
      "inner_a": "inner_color.a",
      "outer_r": "outer_color.r",
      "outer_g": "outer_color.g",
      "outer_b": "outer_color.b",
      "outer_a": "outer_color.a",
    ]
  );

///
struct BackgroundScheduledControllerFactory {
 public:
  @disable this();

  ///
  this(
      in VarStoreInterface varstore,
      Background background) {
    varstore_   = varstore;
    background_ = background;
  }

  ///
  void Create(R)(R params, ContextBuilderInterface builder)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    auto ctrl = new BackgroundScheduledController(
        background_, varstore_, SortParametersBlock(params));
    builder.AddScheduledController(ctrl);
  }

 private:
  const VarStoreInterface varstore_;

  Background background_;
}
