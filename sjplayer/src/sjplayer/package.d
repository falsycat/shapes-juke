/// License: MIT
module sjplayer;

import sjscript;

public {
  import sjplayer.Context,
         sjplayer.ElementProgramSet;
}

///
Context CreateContextFromText(string src, ElementProgramSet programs) {
  return src.CreateScriptAst().CreateContextFromScriptAst(programs);
}
///
Context CreateContextFromScriptAst(
    ParametersBlock[] params, ElementProgramSet programs) {
  // TODO:
  assert(false);
}
