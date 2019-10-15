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

  auto programs = new ProgramSet;
  scope(exit) programs.destroy();

  Context context;
  try {
    context = script_file.readText.
      CreateContextFromText(vec2i(600, 600), programs);
  } catch (ScriptException e) {
    "[parsing exception] %s at (%d,%d)".
      writefln(e.msg, e.pos.stline+1, e.pos.stchar+1);
    return 1;
  }
  scope(exit) context.destroy();

  sfMusic_play(music);
  while (true) {
    sfEvent e;
    sfWindow_pollEvent(win, &e);
    if (e.type == sfEvtClosed) break;

    const msecs = sfMusic_getPlayingOffset(music).microseconds * 1e-6f;
    const beat  = msecs/60f * bpm;

    context.actor.Accelarate(GetAccelarationInput());

    try {
      context.OperateScheduledControllers(beat);
    } catch (ScriptRuntimeException e) {
      "[runtime exception] %s at (%d,%d)".
        writefln(e.msg, e.srcline+1, e.srcchar+1);
      return 1;
    }

    context.actor.Update();
    context.posteffect.Update();

    const dmg = context.CalculateDamage();
    if (dmg.damage != 0) {
      "damage: %f (%f)".writefln(dmg.damage, beat);
      context.posteffect.CauseDamagedEffect();
    }
    if (dmg.nearness != 0) {
      "nearby: %f (%f)".writefln(dmg.nearness, beat);
    }

    gl.Clear(GL_COLOR_BUFFER_BIT);
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
