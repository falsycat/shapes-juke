/// License: MIT
module sjplayer;

import sjscript;

public {
  import sjplayer.ElementProgramSet;
}

///
auto CreateContextFromText(string src, ElementProgramSet programs) {
  return src.CreateScriptAst().CreateContextFromScriptAst(programs);
}
///
auto CreateContextFromScriptAst(
    ParametersBlock[] params, ElementProgramSet programs) {
  // TODO:
  assert(false);
}
