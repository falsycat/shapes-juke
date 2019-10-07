/// License: MIT
module sjplayer.CircleElementScheduledController;

import std.typecons;

import gl4d;

import sjscript;

import sjplayer.CircleElement,
       sjplayer.ScheduledControllerFactory,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface,
       sjplayer.util.MatrixFactory,
       sjplayer.util.Parameter;

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

    matrix_factory_ = matrix_factory_.init;

    super.PrepareOperation(params);
  }
  override void ProcessOperation(float time, ref in ParametersBlock params) {
    super.ProcessOperation(time, params);
    element_.matrix = matrix_factory_.Create().transposed;
  }
  override void FinalizeOperation(ref in ParametersBlock params) {
    element_.alive = false;
  }

  override void SetParameter(Nullable!float time, ref in Parameter param) {
    auto vars = VarStore(this, time);
    switch (param.name) {
      case "damage":       return param.CalculateParameter(element_.damage,       vars);
      case "nearness_coe": return param.CalculateParameter(element_.nearness_coe, vars);
      case "weight":       return param.CalculateParameter(element_.weight,       vars);
      case "smooth":       return param.CalculateParameter(element_.smooth,       vars);
      default:
    }
    if (param.CalculateMatrixParameter(matrix_factory_, vars)) return;

    return super.SetParameter(time, param);
  }

 private:
  CircleElement element_;

  MatrixFactory matrix_factory_;
}

///
alias CircleElementScheduledControllerFactory =
  ElementScheduledControllerFactory!(
      CircleElementScheduledController,
      CircleElementDrawer);
