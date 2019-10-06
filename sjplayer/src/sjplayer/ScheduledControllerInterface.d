/// License: MIT
module sjplayer.ScheduledControllerInterface;

import std.algorithm,
       std.array;

import sjscript;

import sjplayer.util.compare;

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
      FinishOperation(*last_operation);
    }

    if (next_operation_index_ >= operations_.length) return;

    const next_operation = &operations_[next_operation_index_];
    if (IsTimeInPeriod(time, next_operation.period)) {
      PrepareOperation(*next_operation);
      ++next_operation_index_;
    }
  }

 protected:
  abstract void PrepareOperation(ref in ParametersBlock params);

  abstract void ProcessOperation(ref in ParametersBlock params);

  abstract void FinishOperation(ref in ParametersBlock params);

 private:
  const ParametersBlock[] operations_;

  float last_operation_time_ = -1;

  size_t next_operation_index_;
}
