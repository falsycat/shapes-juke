/// License: MIT
module sjplayer.ScheduledController;

import std.traits,
       std.typecons;

import gl4d;

import sjscript;

import sjplayer.AbstractScheduledController,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface,
       sjplayer.util.MatrixFactory,
       sjplayer.util.Parameter;

///
class ScheduledController(
    Target, string[string] ParameterNameMap) : AbstractScheduledController {
 public:
  ///
  enum AliveManagementAvailable =
    is(typeof((Target x) => x.alive)) &&
    is(ReturnType!((Target x) => x.alive) == bool);
  ///
  enum MatrixModificationAvailable =
    is(typeof((Target x) => x.matrix)) &&
    is(ReturnType!((Target x) => x.matrix) == mat3);
  ///
  enum AutoInitializationAvailable =
    is(typeof((Target x) => x.Initialize()));

  ///
  this(
      Target target,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(varstore, operations);
    target_ = target;
  }

 protected:
  override void PrepareOperation(ref in ParametersBlock params) {
    static if (AutoInitializationAvailable) {
      target_.Initialize();
    }
    static if (AliveManagementAvailable) {
      target_.alive = true;
    }
    static if (MatrixModificationAvailable) {
      matrix_factory_ = matrix_factory_.init;
    }
    super.PrepareOperation(params);
  }
  override void ProcessOperation(float time, ref in ParametersBlock params) {
    super.ProcessOperation(time, params);
    static if (MatrixModificationAvailable) {
      target_.matrix = matrix_factory_.Create();
    }
  }
  override void FinalizeOperation(ref in ParametersBlock params) {
    static if (AliveManagementAvailable) {
      target_.alive = false;
    }
  }

  override Nullable!float GetVariable(string name) const {
    switch (name) {
      static foreach (map_name, code; ParameterNameMap) {
        case map_name:
          return Nullable!float(mixin("target_."~code));
      }
      default:
    }
    static if (MatrixModificationAvailable) {
      const value = matrix_factory_.GetValueByName(name);
      if (!value.isNull) return value;
    }
    return super.GetVariable(name);
  }
  override void SetParameter(ref in Parameter param, ref in VarStore vars) {
    switch (param.name) {
      static foreach (map_name, code; ParameterNameMap) {
        case map_name:
          param.CalculateParameter(mixin("target_."~code), vars);
          return;
      }
      default:
    }
    static if (MatrixModificationAvailable) {
      if (param.CalculateMatrixParameter(matrix_factory_, vars)) return;
    }
    super.SetParameter(param, vars);
  }

  Target target_;

  static if (MatrixModificationAvailable) {
    MatrixFactory matrix_factory_;
  }
}
