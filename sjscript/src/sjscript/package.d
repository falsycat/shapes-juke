/// License: MIT
module sjscript;

import std.algorithm;

import dast.tokenize : Tokenize;

import sjscript.Token,
       sjscript.parse,
       sjscript.preprocess;

public {
  import sjscript.Expression,
         sjscript.ParametersBlock,
         sjscript.exception;
}

///
ParametersBlock[] CreateScriptAst(string src) {
  return src.
    Tokenize!TokenType().
    filter!(x => x.type != TokenType.Whitespace).
    Preprocess().
    Parse();
}
