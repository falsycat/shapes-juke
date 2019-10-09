/// License: MIT
module sjplayer;

import gl4d;

import sjscript;

public {
  import sjplayer.Context,
         sjplayer.ProgramSet;
}

///
Context CreateContextFromText(string src, vec2i window_size, ProgramSet programs) {
  return src.CreateScriptAst().CreateContextFromScriptAst(window_size, programs);
}
///
Context CreateContextFromScriptAst(
    ParametersBlock[] params, vec2i window_size, ProgramSet programs) {
  return new Context(params, window_size, programs);
}
