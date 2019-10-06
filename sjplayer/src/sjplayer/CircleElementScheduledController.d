/// License: MIT
module sjplayer.CircleElementScheduledController;

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
    element_.matrix       = mat3.identity;
    element_.weight       = 1;
    element_.smooth       = 0;
    element_.color        = vec4(1, 1, 1, 1);
  }
  override void FinalizeOperation(ref in ParametersBlock params) {
    element_.alive = false;
  }

  override float GetVariable(string name) const {
    throw new Exception("not implemented");  // TODO:
  }
  override void SetParameter(ref in Parameter param) {
    throw new Exception("not implemented");  // TODO:
  }

 private:
  CircleElement element_;
}

///
alias CircleElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      CircleElementScheduledController,
      CircleElementDrawer);
