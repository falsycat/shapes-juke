/// License: MIT
import std;

import derelict.sfml2.audio,
       derelict.sfml2.system,
       derelict.sfml2.window;

import gl4d;

import sjplayer;

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

  auto programs = new ProgramSet;
  scope(exit) programs.destroy();

  auto context = script_file.readText.
    CreateContextFromText(vec2i(600, 600), programs);
  scope(exit) context.destroy();

  while (true) {
    sfEvent e;
    sfWindow_pollEvent(win, &e);
    if (e.type == sfEvtClosed) break;

    const msecs = sfMusic_getPlayingOffset(music).microseconds * 1e-6f;
    const beat  = msecs/60f * bpm;

    context.actor.Accelarate(GetAccelarationInput());

    context.OperateScheduledControllers(beat);
    context.actor.Update();
    context.posteffect.Update();

    const dmg = context.CalculateDamage();
    if (dmg.damage != 0) {
      "damage: %f (%f)".writefln(dmg.damage, beat);
    }
    if (dmg.nearness != 0) {
      "nearness: %f (%f)".writefln(dmg.nearness, beat);
    }

    context.StartDrawing();

    context.DrawBackground();
    context.DrawElements();
    context.DrawActor();

    context.EndDrawing();
    sfWindow_display(win);
  }
  return 0;
}

vec2 GetAccelarationInput() {
  auto result = vec2(0, 0);
  if (sfKeyboard_isKeyPressed(sfKeyLeft)) {
    result.x -= 1;
  }
  if (sfKeyboard_isKeyPressed(sfKeyRight)) {
    result.x += 1;
  }
  if (sfKeyboard_isKeyPressed(sfKeyUp)) {
    result.y += 1;
  }
  if (sfKeyboard_isKeyPressed(sfKeyDown)) {
    result.y -= 1;
  }
  return result;
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
