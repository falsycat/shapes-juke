/// License: MIT
module sjplayer.ElementScheduledController;

import std.traits,
       std.typecons;

import gl4d;

import sjscript;

import sjplayer.ElementInterface,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface,
       sjplayer.util.MatrixFactory,
       sjplayer.util.Parameter;

///
class ElementScheduledController(
    Element, string[string] ParameterNameMap) :
  AbstractScheduledControllerWithOperationImpl {
 public:
  ///
  enum AliveManagementAvailable =
    is(typeof((Element e) => e.alive)) &&
    is(ReturnType!((Element e) => e.alive) == bool);
  ///
  enum MatrixModificationAvailable =
    is(typeof((Element e) => e.matrix)) &&
    is(ReturnType!((Element e) => e.matrix) == mat3);

  ///
  this(
      Element element,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(varstore, operations);
    element_ = element;
  }

 protected:
  override void PrepareOperation(ref in ParametersBlock params) {
    element_.Initialize();
    static if (AliveManagementAvailable) {
      element_.alive = true;
    }
    static if (MatrixModificationAvailable) {
      matrix_factory_ = matrix_factory_.init;
    }
    super.PrepareOperation(params);
  }
  override void ProcessOperation(float time, ref in ParametersBlock params) {
    super.ProcessOperation(time, params);
    static if (MatrixModificationAvailable) {
      element_.matrix = matrix_factory_.Create().transposed;
    }
  }
  override void FinalizeOperation(ref in ParametersBlock params) {
    static if (AliveManagementAvailable) {
      element_.alive = false;
    }
  }

  override float GetVariable(string name) const {
    switch (name) {
      static foreach (map_name, code; ParameterNameMap) {
        case map_name:
          return mixin("element_."~code);
      }
      default: return super.GetVariable(name);
    }
  }
  override void SetParameter(Nullable!float time, ref in Parameter param) {
    auto vars = VarStore(this, time);
    switch (param.name) {
      static foreach (map_name, code; ParameterNameMap) {
        case map_name:
          param.CalculateParameter(mixin("element_."~code), vars);
          return;
      }
      default:
    }
    static if (MatrixModificationAvailable) {
      if (param.CalculateMatrixParameter(matrix_factory_, vars)) return;
    }
    super.SetParameter(time, param);
  }

  Element element_;

  static if (MatrixModificationAvailable) {
    MatrixFactory matrix_factory_;
  }
}
