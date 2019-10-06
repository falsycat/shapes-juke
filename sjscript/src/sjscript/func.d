/// License: MIT
module sjscript.func;

import std.algorithm,
       std.exception,
       std.math;

///
float CallFunction(string name, float[] args) {
  void EnforceArgs(size_t len)() {
    (args.length == len).enforce("invalid arguments");
  }

  switch (name) {
    // ---- misc
    case "abs":  EnforceArgs!1; return fabs(args[0]);
    case "sqrt": EnforceArgs!1; return sqrt(args[0]);
    case "exp":  EnforceArgs!1; return exp(args[0]);
    case "pow":  EnforceArgs!2; return pow(args[0], args[1]);

    // ---- triangle
    case "sin": EnforceArgs!1; return sin(args[0]);
    case "cos": EnforceArgs!1; return cos(args[0]);
    case "tan": EnforceArgs!1; return tan(args[0]);

    case "asin": EnforceArgs!1; return asin(args[0]);
    case "acos": EnforceArgs!1; return acos(args[0]);
    case "atan": EnforceArgs!1; return atan(args[0]);

    case "atan2": EnforceArgs!2; return atan2(args[0], args[1]);

    // ---- rounding
    case "ceil":  EnforceArgs!1; return ceil(args[0]);
    case "floor": EnforceArgs!1; return floor(args[0]);
    case "round": EnforceArgs!1; return round(args[0]);

    // ---- conditional switch
    case "step":  EnforceArgs!2; return args[1] > args[0]? 1: 0;
    case "clamp": EnforceArgs!3; return clamp(args[0], args[1], args[2]);

    default: throw new Exception("unknown exception");
  }
}
