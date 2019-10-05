#!/usr/bin/env dub
/+ dub.json:
{
  "name": "sjplayer",
  "dependencies": {
    "sjscript": {"path": "../sjscript"},
    "derelict-sfml2": "~>4.0.0-beta.2"
  },
  "lflags-posix":   ["-L../thirdparty/dsfml/lib"],
  "lflags-windows": ["/LIBPATH:..\\thirdparty\\dsfml\\lib\\"]
} +/

import std;

import derelict.sfml2.audio,
       derelict.sfml2.system,
       derelict.sfml2.window;

int main(string[] args) {
  DerelictSFML2System.load();
  DerelictSFML2Window.load();
  DerelictSFML2Audio.load();

  sfContextSettings specs;
  specs.depthBits         = 32;
  specs.stencilBits       = 32;
  specs.antialiasingLevel = 1;
  specs.majorVersion      = 3;
  specs.minorVersion      = 3;

  auto win = sfWindow_create(
      sfVideoMode(600, 600), "sjplayer".toStringz, sfDefaultStyle, &specs);
  scope(exit) sfWindow_destroy(win);

  sfWindow_setActive(win, true);

  auto running = true;
  while (running) {
    sfEvent e;
    sfWindow_pollEvent(win, &e);

    running = e.type != sfEvtClosed;

    sfWindow_display(win);
  }
  return 0;
}
