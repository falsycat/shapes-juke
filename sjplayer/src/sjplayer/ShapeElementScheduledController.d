/// License: MIT
module sjplayer.ShapeElementScheduledController;

import std.algorithm,
       std.array,
       std.conv,
       std.range.primitives,
       std.traits,
       std.typecons;

import gl4d;

import sjscript;

import sjplayer.AbstractShapeElement,
       sjplayer.ContextBuilderInterface,
       sjplayer.ProgramSet,
       sjplayer.ScheduledController,
       sjplayer.ShapeElementScheduledController,
       sjplayer.VarStoreInterface,
       sjplayer.util.Parameter,
       sjplayer.util.Period;

private enum NameMap = [
  "damage":       "damage",
  "nearness_coe": "nearness_coe",
  "weight":       "weight",
  "smooth":       "smooth",
  "color_r":      "color.r",
  "color_g":      "color.g",
  "color_b":      "color.b",
  "color_a":      "color.a",
];

///
class ShapeElementScheduledController :
  ScheduledController!(AbstractShapeElement, NameMap) {
 public:
  ///
  this(
      AbstractShapeElement shape,
      in VarStoreInterface varstore,
      in ParametersBlock[] operations) {
    super(shape, varstore, operations);
    shape_ = shape;
  }

 protected:
  override void PrepareOperation(ref in ParametersBlock params) {
    shape_.Initialize();
    shape_.alive = true;

    matrix_factory_ = matrix_factory_.init;
    super.PrepareOperation(params);
  }
  override void ProcessOperation(float time, ref in ParametersBlock params) {
    super.ProcessOperation(time, params);
    shape_.matrix = matrix_factory_.Create();
  }
  override void FinalizeOperation(ref in ParametersBlock params) {
    shape_.alive = false;
  }

  override Nullable!float GetVariable(string name) const {
    const value = matrix_factory_.
      GetModelMatrixParameterValueByName(name);
    if (!value.isNull) return value;

    return super.GetVariable(name);
  }
  override void SetParameter(ref in Parameter param, ref in VarStore vars) {
    if (param.CalculateModelMatrixParameter(matrix_factory_, vars)) return;
    super.SetParameter(param, vars);
  }

 private:
  AbstractShapeElement shape_;

  ModelMatrixFactory!3 matrix_factory_;
}

///
struct ShapeElementScheduledControllerFactory(ShapeElement, ShapeElementDrawer)
  if (is(ShapeElement : AbstractShapeElement)) {
 public:
  ///
  alias ShapeElementProgram =
    Parameters!(__traits(getOverloads, ShapeElementDrawer, "__ctor")[0])[0];

  ///
  this(ProgramSet programs, VarStoreInterface varstore) {
    program_  = programs.Get!ShapeElementProgram;
    varstore_ = varstore;
  }

  ///
  void Create(R)(R params, ContextBuilderInterface builder)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    auto parallelized = ParallelizeParams(params);
    auto elements     = appender!(ShapeElement[]);

    foreach (ref serial; parallelized) {
      auto element = new ShapeElement;
      elements    ~= element;
      builder.AddElement(element);
      builder.AddScheduledController(
          new ShapeElementScheduledController(element, varstore_, serial));
    }
    if (elements[].length > 0) {
      builder.AddElementDrawer(new ShapeElementDrawer(program_, elements[]));
    }
  }

 private:
  static ParametersBlock[][] ParallelizeParams(R)(R params)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    ParametersBlock[][] parallelized;
    foreach (ref param; params) {
      auto inserted = false;
      foreach (ref serial; parallelized) {
        const found_index = serial.
          countUntil!(x => x.period.start > param.period.start);
        const insert_index =
          found_index >= 0? found_index.to!size_t: serial.length;

        const intersect_prev = insert_index >= 1 &&
          IsPeriodIntersectedToPeriod(serial[insert_index-1].period, param.period);
        const intersect_next = insert_index < serial.length &&
          IsPeriodIntersectedToPeriod(serial[insert_index].period, param.period);

        if (!intersect_prev && !intersect_next) {
          serial   = serial[0..insert_index]~ param ~serial[insert_index..$];
          inserted = true;
          break;
        }
      }
      if (!inserted) {
        parallelized ~= [param];
      }
    }
    return parallelized;
  }

  ShapeElementProgram program_;

  VarStoreInterface varstore_;
}
