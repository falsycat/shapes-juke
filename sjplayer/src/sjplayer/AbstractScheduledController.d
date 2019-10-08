/// License: MIT
module sjplayer.AbstractScheduledController;

import std.algorithm,
       std.array,
       std.exception,
       std.range.primitives,
       std.typecons;

import sjscript;

import sjplayer.ScheduledControllerInterface,
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
    FinalizeCurrentOperationIfEnded(time);
    PrepareNextOperationIfStarted(time);
    ProcessCurrentOperationIfAvailable(time);
  }

 protected:
  static struct VarStore {
   public:
    float opIndex(string name) const {
      if (!time_.isNull && name == "time") return time_.get;
      return this_.GetVariable(name);
    }
   private:
    AbstractScheduledController this_;
    Nullable!float              time_;
  }

  void PrepareOperation(ref in ParametersBlock params) {
    user_vars_.clear();

    auto vars = VarStore(this);
    params.parameters.
      filter!(x => x.type == ParameterType.OnceAssign).
      each  !(x => SetParameter(x, vars));
  }
  void ProcessOperation(float time, ref in ParametersBlock params) {
    auto vars = VarStore(this, time.nullable);
    params.parameters.
      filter!(x => x.type != ParameterType.OnceAssign).
      each  !(x => SetParameter(x, vars));
  }
  void FinalizeOperation(ref in ParametersBlock params) {
  }

  float GetVariable(string name) const {
    if (name in user_vars_) return user_vars_[name];
    return varstore_[name];
  }
  void SetParameter(ref in Parameter param, ref in VarStore vars) {
    (param.name.length >= 2 && param.name[0..2] == "__").
      enforce("user defined variables must be prefixed '__'");
    user_vars_[param.name] = 0;
    param.CalculateParameter(user_vars_[param.name], vars);
  }

 private:
  void FinalizeCurrentOperationIfEnded(float time) {
    if (next_operation_index_ < 1) return;

    const current = &operations_[next_operation_index_-1];
    if (current.period.end > time) return;

    FinalizeOperation(*current);
  }
  void PrepareNextOperationIfStarted(float time) {
    if (next_operation_index_ >= operations_.length) return;

    const next = &operations_[next_operation_index_];
    if (next.period.start > time) return;

    ++next_operation_index_;
    PrepareOperation(*next);
  }
  void ProcessCurrentOperationIfAvailable(float time) {
    if (next_operation_index_ < 1) return;

    const current = &operations_[next_operation_index_-1];
    if (current.period.end <= time) return;

    ProcessOperation(
        current.period.ConvertToRelativeTime(time), *current);
  }

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
    (!param.period.IsPeriodIntersectedToPeriod(before)).enforce();
  }
  return result;
}
