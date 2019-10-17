/// License: MIT
module sjplayer.AbstractScheduledController;

import std.algorithm,
       std.array,
       std.exception,
       std.format,
       std.range.primitives,
       std.typecons;

import sjscript;

import sjplayer.ScriptRuntimeException,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface,
       sjplayer.util.Parameter,
       sjplayer.util.Period;

///
abstract class AbstractScheduledController : ScheduledControllerInterface {
 public:
  ///
  this(in VarStoreInterface varstore, in ParametersBlock[] operations) {
    varstore_   = varstore;
    operations_ = operations;
  }

  override void Operate(float time) {
    while (true) {
      if (next_operation_index_ >= 1) {
        const current = &operations_[next_operation_index_-1];
        ProcessOperation(
            current.period.ConvertToRelativeTime(time).clamp(0f, 1f), *current);
        if (current.period.end > time) return;
        FinalizeOperation(*current);
      }

      if (next_operation_index_ >= operations_.length) return;

      const next = &operations_[next_operation_index_];
      if (next.period.start > time) return;
      ++next_operation_index_;
      PrepareOperation(*next);
    }
  }

 protected:
  static struct VarStore {
   public:
    float opIndex(string name) const {
      if (!time_.isNull && name == "time") return time_.get;
      const temp = this_.GetVariable(name);
      if (!temp.isNull) return temp.get;

      throw new ScriptRuntimeException(
          "unknown variable `%s`".format(name), srcline_, srcchar_);
    }
   private:
    AbstractScheduledController this_;
    Nullable!float              time_;

    size_t srcline_, srcchar_;
  }

  void PrepareOperation(ref in ParametersBlock params) {
    user_vars_.clear();

    auto vars = VarStore(
        this, Nullable!float.init, params.pos.stline, params.pos.stchar);
    params.parameters.
      filter!(x => x.type == ParameterType.OnceAssign).
      each  !(x => SetParameter(x, vars));
  }
  void ProcessOperation(float time, ref in ParametersBlock params) {
    auto vars = VarStore(
        this, time.nullable, params.pos.stline, params.pos.stchar);
    params.parameters.
      filter!(x => x.type != ParameterType.OnceAssign).
      each  !(x => SetParameter(x, vars));
  }
  void FinalizeOperation(ref in ParametersBlock params) {
  }

  Nullable!float GetVariable(string name) const {
    if (name in user_vars_) {
      return Nullable!float(user_vars_[name]);
    }
    auto temp = varstore_[name];
    if (!temp.isNull) return temp;
    return StandardVarStore.GetByName(name);
  }
  void SetParameter(ref in Parameter param, ref in VarStore vars) {
    if (param.name.length < 2 || param.name[0..2] != "__") {
      throw new ScriptRuntimeException(
          "user defined variables must be prefixed as '__'",
          param.pos.stline, param.pos.stchar);
    }
    user_vars_[param.name] = 0;
    param.CalculateParameter(user_vars_[param.name], vars);
  }

 private:
  const VarStoreInterface varstore_;

  const ParametersBlock[] operations_;

  size_t next_operation_index_;

  float[string] user_vars_;
}

///
ParametersBlock[] SortParametersBlock(R)(R params)
    if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
  auto result = params.array;
  result.sort!"a.period.start < b.period.start";

  auto before = Period(-1, 0);
  foreach (param; result) {
    if (param.period.IsPeriodIntersectedToPeriod(before)) {
      throw new ScriptRuntimeException(
          "the period is duplicated",
          param.pos.stline, param.pos.stchar);
    }
  }
  return result;
}
