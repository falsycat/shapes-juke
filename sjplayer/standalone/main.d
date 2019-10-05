/// License: MIT
import std;

import derelict.sfml2.audio,
       derelict.sfml2.system,
       derelict.sfml2.window;

import gl4d;

int main(string[] args) {
  (args.length == 4).enforce;
  const music_file  = args[1];
  const bpm         = args[2].to!float;
  const script_file = args[3];

  auto win = Initialize();
  scope(exit) sfWindow_destroy(win);

  auto music = sfMusic_createFromFile(music_file.toStringz).enforce;
  scope(exit) sfMusic_destroy(music);
  sfMusic_play(music);

  import sjplayer.ElementProgramSet;
  auto programs = new ElementProgramSet;
  scope(exit) programs.destroy();

  import sjplayer.CircleElement;
  auto element = new CircleElement;
  scope(exit) element.destroy();
  auto drawer  = new CircleElementDrawer(programs.Get!CircleElementProgram, [element]);
  scope(exit) drawer.destroy();

  with (element) {
    alive  = true;

    matrix = mat3.identity;
    matrix.scale(0.5, 0.5, 0.5);
    matrix.translate(0.1, 0, 0);
    matrix.transpose();

    weight = 1;
    smooth = 0.01;
    color  = vec4(1, 1, 1, 1);
  }

  while (true) {
    sfEvent e;
    sfWindow_pollEvent(win, &e);
    if (e.type == sfEvtClosed) break;

    const msecs = sfMusic_getPlayingOffset(music).microseconds * 1e-6f;
    const beat  = msecs/60f * bpm;
    drawer.Draw();

    sfWindow_display(win);
  }
  return 0;
}

sfWindow* Initialize() {
  DerelictSFML2System.load();
  DerelictSFML2Window.load();
  DerelictSFML2Audio .load();

  sfContextSettings specs;
  specs.depthBits         = 24;
  specs.stencilBits       = 8;
  specs.antialiasingLevel = 1;
  specs.majorVersion      = 3;
  specs.minorVersion      = 3;
  specs.attributeFlags    = sfContextCore;

  auto win = sfWindow_create(sfVideoMode(600, 600),
      "sjplayer".toStringz, sfClose | sfTitlebar, &specs).enforce;
  sfWindow_setVerticalSyncEnabled(win, true);

  sfWindow_setActive(win, true).enforce;

  gl.ApplyContext();
  gl.Enable(GL_BLEND);
  gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  return win;
}
