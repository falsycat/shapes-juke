/// License: MIT
module sjplayer.ScheduledControllerFactory;

import std.algorithm,
       std.array,
       std.conv,
       std.meta,
       std.range.primitives,
       std.traits;

import sjscript;

import sjplayer.ElementInterface,
       sjplayer.ElementProgramSet,
       sjplayer.ScheduledControllerInterface,
       sjplayer.VarStoreInterface,
       sjplayer.util.compare;

///
struct ScheduledControllerCreationResult {
  ///
  ElementInterface[] elements;
  ///
  ScheduledControllerInterface[] controllers;

  ///
  ElementDrawerInterface drawer;
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
        ElementProgram, ElementProgramSet.ElementPrograms.Types) >= 0);
  static assert(is(Element[] :
    Parameters!(__traits(getOverloads, ElementDrawer, "__ctor")[0])[1]));

  ///
  this(ElementProgramSet programs, VarStoreInterface varstore) {
    program_  = programs.Get!ElementProgram;
    varstore_ = varstore;
  }

  ///
  ScheduledControllerCreationResult Create(R)(R params)
      if (isInputRange!R && is(ElementType!R == ParametersBlock)) {
    auto parallelized = params.ParallelizeParams();

    auto elements    = appender!(Element[]);
    auto controllers = appender!(ScheduledController[]);

    foreach (ref serial; parallelized) {
      auto element = new Element;
      elements    ~= element;
      controllers ~= new ScheduledController(element, varstore_, serial);
    }
    return ScheduledControllerCreationResult(
        cast(ElementInterface[])             elements[],
        cast(ScheduledControllerInterface[]) controllers[],
        new ElementDrawer(program_, elements[]));
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
