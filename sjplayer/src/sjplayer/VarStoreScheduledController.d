/// License: MIT
module sjplayer.VarStoreScheduledController;

import std.range.primitives;

import sjscript;

import sjplayer.AbstractScheduledController,
       sjplayer.ContextBuilderInterface,
       sjplayer.VarStore,
       sjplayer.util.Parameter;

///
class VarStoreScheduledController : AbstractScheduledController {
 public:
  ///
  alias VarStore = sjplayer.VarStore.VarStore;

  ///
  this(VarStore varstore, in ParametersBlock[] operations) {
    super(varstore, operations);
    varstore_ = varstore;
  }

 protected:
  override void SetParameter(
      ref in Parameter param,
      ref in AbstractScheduledController.VarStore vars) {
    const x_nullable = varstore_[param.name];
    auto  x          = x_nullable.isNull? 0f: x_nullable.get;
    param.CalculateParameter(x, vars);
    varstore_[param.name] = x;
  }

 private:
  VarStore varstore_;
}

///
struct VarStoreScheduledControllerFactory {
 public:
  ///
  this(VarStore varstore) {
    varstore_ = varstore;
  }

  ///
  void Create(R)(R params, ContextBuilderInterface builder)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    auto product = new VarStoreScheduledController(
        varstore_, SortParametersBlock(params));
    builder.AddScheduledController(product);
  }

 private:
  VarStore varstore_;
}
