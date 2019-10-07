/// License: MIT
module sjplayer;

import sjscript;

public {
  import sjplayer.Context,
         sjplayer.ProgramSet;
}

///
Context CreateContextFromText(string src, ProgramSet programs) {
  return src.CreateScriptAst().CreateContextFromScriptAst(programs);
}
///
Context CreateContextFromScriptAst(
    ParametersBlock[] params, ProgramSet programs) {
  return new Context(params, programs);
}
