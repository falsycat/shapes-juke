/// License: MIT
module sjplayer.ScheduledController;

import std.typecons;

import gl4d;

import sjscript;

import sjplayer.AbstractScheduledController,
       sjplayer.VarStoreInterface,
       sjplayer.util.Parameter;

///
class ScheduledController(
    Target, string[string] ParameterNameMap) : AbstractScheduledController {
 public:
  ///
  this(
      Target target,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(varstore, operations);
    target_ = target;
  }

 protected:
  override Nullable!float GetVariable(string name) const {
    switch (name) {
      static foreach (map_name, code; ParameterNameMap) {
        case map_name:
          return Nullable!float(mixin("target_."~code));
      }
      default:
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
    super.SetParameter(param, vars);
  }

  Target target_;
}
