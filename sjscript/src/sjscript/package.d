/// License: MIT
module sjscript;

import std.algorithm,
       std.range;

import dast.tokenize : Tokenize;

import sjscript.Token,
       sjscript.parse,
       sjscript.preprocess;

public {
  import sjscript.ParametersBlock,
         sjscript.ScriptException,
         sjscript.calculate;
}

///
ParametersBlock[] CreateScriptAst(string src) {
  return src.
    Tokenize!TokenType().
    filter!(x => x.type != TokenType.Whitespace).
    filter!(x => x.type != TokenType.Comment).
    chain([Token("", TokenType.End)]).
    Preprocess().
    Parse();
}
