#!/usr/bin/env dub

/+ dub.json:
{
  "name": "test",

  "dependencies": {
    "ft4d": {"path": "."}
  }
}
+/

import std;
import ft4d;

void main() {
  ft.Initialize();
  assert(ft.IsInitialized);
  scope(exit) ft.Dispose();

  auto face = Face.CreateFromPath("/usr/share/fonts/TTF/Ricty-Regular.ttf");

  GlyphLoader loader;
  loader.pxWidth  = 16;
  loader.pxHeight = 0;
  loader.flags    = FT_LOAD_DEFAULT | FT_LOAD_RENDER;

  loader.character = 'a';
  loader.Load(face).enforce();

  face.EnforceGlyphBitmap().writeln;
}
