/// License: MIT
module sjplayer.ScheduledControllerInterface;

import std.algorithm,
       std.array,
       std.exception,
       std.format,
       std.typecons;

import sjscript;

import sjplayer.VarStoreInterface,
       sjplayer.util.compare;

///
interface ScheduledControllerInterface {
 public:
  ///
  void Operate(float time);
}

///
abstract class AbstractScheduledController : ScheduledControllerInterface {
 public:
  /// The operations must be sorted.
  this(in ParametersBlock[] operations) {
    operations_ = operations;
  }

  override void Operate(float time) {
    scope(exit) last_operation_time_ = time;

    if (next_operation_index_ >= 1) {
      assert(next_operation_index_ <= operations_.length);

      const last_operation = &operations_[next_operation_index_-1];
      if (IsTimeInPeriod(time, last_operation.period)) {
        ProcessOperation(time, *last_operation);
        return;
      }
      FinalizeOperation(*last_operation);
    }

    if (next_operation_index_ >= operations_.length) return;

    const next_operation = &operations_[next_operation_index_];
    if (IsTimeInPeriod(time, next_operation.period)) {
      PrepareOperation(*next_operation);
      ProcessOperation(time, *next_operation);
      ++next_operation_index_;
    }
  }

 protected:
  abstract void PrepareOperation(ref in ParametersBlock params);

  abstract void ProcessOperation(float time, ref in ParametersBlock params);

  abstract void FinalizeOperation(ref in ParametersBlock params);

 private:
  const ParametersBlock[] operations_;

  float last_operation_time_ = -1;

  size_t next_operation_index_;
}

///
abstract class AbstractScheduledControllerWithOperationImpl :
  AbstractScheduledController {
 public:
  ///
  this(in VarStoreInterface varstore, in ParametersBlock[] operations) {
    super(operations);
    varstore_ = varstore;
  }

 protected:
  static struct VarStore {
   public:
    float opIndex(string name) {
      if (!time_.isNull && name == "time") return time_.get;
      return this_.GetVariable(name);
    }
   private:
    AbstractScheduledControllerWithOperationImpl this_;
    Nullable!float time_;
  }

  override void PrepareOperation(ref in ParametersBlock params) {
    params.parameters.
      filter!(x => x.type == ParameterType.OnceAssign).
      each  !(x => SetParameter(Nullable!float.init, x));
  }
  override void ProcessOperation(float time, ref in ParametersBlock params) {
    params.parameters.
      filter!(x => x.type != ParameterType.OnceAssign).
      each  !(x => SetParameter(time.nullable, x));
  }

  float GetVariable(string name) const {
    if (name in user_vars_) return user_vars_[name];
    return varstore_[name];
  }
  void SetParameter(Nullable!float time, ref in Parameter param) {
    (param.name.length >= 2 && param.name[0..2] == "__").
      enforce("user defined variables must be prefixed '__'");

    auto value = param.rhs.CalculateExpression(VarStore(this, time));
    if (param.type == ParameterType.AddAssign) {
      value += user_vars_[param.name];
    }
    user_vars_[param.name] = value;
  }

 private:
  const VarStoreInterface varstore_;

  float[string] user_vars_;
}
