/// License: MIT
module sjplayer.ScheduledControllerInterface;

import std.algorithm,
       std.array,
       std.exception,
       std.format;

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
        ProcessOperation(*last_operation);
        return;
      }
      FinalizeOperation(*last_operation);
    }

    if (next_operation_index_ >= operations_.length) return;

    const next_operation = &operations_[next_operation_index_];
    if (IsTimeInPeriod(time, next_operation.period)) {
      PrepareOperation(*next_operation);
      ProcessOperation(*next_operation);
      ++next_operation_index_;
    }
  }

 protected:
  abstract void PrepareOperation(ref in ParametersBlock params);

  abstract void ProcessOperation(ref in ParametersBlock params);

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
      float result = void;
      if (!this_.GetVariable(name).collectException(result)) return result;
      if (!this_.varstore_[name]  .collectException(result)) return result;
      if (!this_.user_vars_[name] .collectException(result)) return result;
      throw new Exception("unknown variable %s".format(name));
    }
   private:
    AbstractScheduledControllerWithOperationImpl this_;
  }

  override void ProcessOperation(ref in ParametersBlock params) {
    foreach (const ref param; params.parameters) {
      if (param.name.length >= 2 && param.name[0..2] == "__") {
        user_vars_[param.name[2..$]] =
          param.rhs.CalculateExpression(VarStore(this));
        continue;
      }
      SetParameter(param);
    }
  }

  abstract float GetVariable(string name) const;

  abstract void SetParameter(ref in Parameter param);

 private:
  const VarStoreInterface varstore_;

  float[string] user_vars_;
}
