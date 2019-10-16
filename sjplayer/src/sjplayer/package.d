/// License: MIT
module sjplayer;

import gl4d;

import sjscript;

public {
  import sjscript : ScriptException;

  import sjplayer.Context,
         sjplayer.PostEffect,
         sjplayer.ProgramSet,
         sjplayer.ScriptRuntimeException;
}

///
Context CreateContextFromText(string src, PostEffect posteffect, ProgramSet programs) {
  return src.CreateScriptAst().CreateContextFromScriptAst(posteffect, programs);
}
///
Context CreateContextFromScriptAst(
    ParametersBlock[] params, PostEffect posteffect, ProgramSet programs) {
  return new Context(params, posteffect, programs);
}
