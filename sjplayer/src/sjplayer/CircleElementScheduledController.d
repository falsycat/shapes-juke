/// License: MIT
module sjplayer.CircleElementScheduledController;

import std.typecons;

import gl4d;

import sjscript;

import sjplayer.CircleElement,
       sjplayer.ScheduledControllerFactory,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface;

///
class CircleElementScheduledController :
  AbstractScheduledControllerWithOperationImpl {
 public:
  ///
  this(
      CircleElement        element,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(varstore, operations);
    element_ = element;
  }

 protected:
  override void PrepareOperation(ref in ParametersBlock params) {
    element_.alive        = true;
    element_.damage       = 0;
    element_.nearness_coe = 0;
    element_.matrix       = mat3.identity.transposed;
    element_.weight       = 1;
    element_.smooth       = 0.01;
    element_.color        = vec4(1, 1, 1, 1);
    super.PrepareOperation(params);
  }
  override void FinalizeOperation(ref in ParametersBlock params) {
    element_.alive = false;
  }

  override void SetParameter(Nullable!float time, ref in Parameter param) {
    // TODO:
    super.SetParameter(time, param);
  }

 private:
  CircleElement element_;
}

///
alias CircleElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      CircleElementScheduledController,
      CircleElementDrawer);
