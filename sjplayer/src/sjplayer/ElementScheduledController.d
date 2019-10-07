/// License: MIT
module sjplayer.ElementScheduledController;

import std.algorithm,
       std.array,
       std.conv,
       std.meta,
       std.range.primitives,
       std.traits,
       std.typecons;

import gl4d;

import sjscript;

import sjplayer.ContextBuilderInterface,
       sjplayer.ElementInterface,
       sjplayer.ProgramSet,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface,
       sjplayer.util.MatrixFactory,
       sjplayer.util.Parameter,
       sjplayer.util.Period;

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

///
struct ElementScheduledControllerFactory(ScheduledController, ElementDrawer)
  if (is(ScheduledController : ScheduledControllerInterface) &&
      is(ElementDrawer : ElementDrawerInterface)) {
 public:
  /// ScheduledController's first constructor's first argument type.
  alias Element =
    Parameters!(__traits(getOverloads, ScheduledController, "__ctor")[0])[0];

  static assert(is(Element : ElementInterface));

  /// ElementDrawer's first constructor's first argument type.
  alias ElementProgram =
    Parameters!(__traits(getOverloads, ElementDrawer, "__ctor")[0])[0];

  static assert(staticIndexOf!(
        ElementProgram, ProgramSet.Programs.Types) >= 0);
  static assert(is(Element[] :
    Parameters!(__traits(getOverloads, ElementDrawer, "__ctor")[0])[1]));

  ///
  this(ProgramSet programs, VarStoreInterface varstore) {
    program_  = programs.Get!ElementProgram;
    varstore_ = varstore;
  }

  ///
  void Create(R)(R params, ContextBuilderInterface builder)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    auto parallelized = params.ParallelizeParams();
    auto elements     = appender!(Element[]);

    foreach (ref serial; parallelized) {
      auto element = new Element;
      elements    ~= element;
      builder.AddElement(element);
      builder.AddScheduledController(
          new ScheduledController(element, varstore_, serial));
    }
    if (elements[].length > 0) {
      builder.AddElementDrawer(new ElementDrawer(program_, elements[]));
    }
  }

 private:
  ElementProgram    program_;
  VarStoreInterface varstore_;
}

private ParametersBlock[][] ParallelizeParams(R)(R params)
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
