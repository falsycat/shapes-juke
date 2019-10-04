#!/usr/bin/env dub
/+ dub.json:
{
  "name": "parse",
  "dependencies": {
    "sjscript": {"path": "../"}
  }
} +/

import std;

import sjscript;

int main(string[] args) {
  enforce(args.length >= 2);
  args[1].readText.CreateScriptAst().writeln;
  return 0;
}
