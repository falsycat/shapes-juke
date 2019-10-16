/// License: MIT
import std;

import derelict.sfml2.audio,
       derelict.sfml2.graphics,
       derelict.sfml2.system,
       derelict.sfml2.window;

import gl4d, ft4d;

import sj.Args,
       sj.Game,
       sj.KeyInput;

enum WindowTitle = "shapes-juke";

int main(string[] unparsed_args) {
  Args args;
  if (!ParseArgs(unparsed_args, args)) return 1;

  auto win  = CreateWindow(args);
  auto game = new Game(args);
  scope(exit) game.destroy();

  while (true) {
    sfEvent e;
    sfWindow_pollEvent(win, &e);
    if (e.type == sfEvtClosed) break;

    game.Update(GetKeyInput());
    game.Draw();
    win.Flush();
  }
  return 0;
}

private bool ParseArgs(string[] unparsed_args, out Args args) {
  auto helpinfo = unparsed_args.getopt(
      "debug-music-offset-beat", &args.debug_music_offset_beat,
      "debug-music-index",       &args.debug_music_index,
      "window-size",             &args.window_size
    );

  auto valid = true;
  if (args.debug_music_offset_beat < 0) {
    "invalid music offset (it should be 0 or more)".writeln;
    valid = false;
  }
  if (args.window_size <= 100) {
    "invalid window size (it should be 100 or more)".writeln;
    valid = false;
  }

  if (!valid || helpinfo.helpWanted) {
    defaultGetoptPrinter(WindowTitle, helpinfo.options);
    return false;
  }
  return true;
}

private KeyInput GetKeyInput() {
  KeyInput result;
  result.left  = !!sfKeyboard_isKeyPressed(sfKeyLeft);
  result.right = !!sfKeyboard_isKeyPressed(sfKeyRight);
  result.up    = !!sfKeyboard_isKeyPressed(sfKeyUp);
  result.down  = !!sfKeyboard_isKeyPressed(sfKeyDown);
  return result;
}

private auto CreateWindow(ref in Args args) {
  ft.Initialize();

  DerelictSFML2Audio   .load();
  DerelictSFML2Graphics.load();
  DerelictSFML2System  .load();
  DerelictSFML2Window  .load();

  sfContextSettings specs;
  specs.depthBits         = 24;
  specs.stencilBits       = 8;
  specs.antialiasingLevel = 1;
  specs.majorVersion      = 3;
  specs.minorVersion      = 3;
  specs.attributeFlags    = sfContextCore;

  auto win = sfWindow_create(
      sfVideoMode(args.window_size, args.window_size),
      WindowTitle.toStringz,
      sfClose | sfTitlebar,
      &specs).
    enforce;

  sfWindow_setVerticalSyncEnabled(win, true);
  sfWindow_setActive(win, true).enforce;

  gl.ApplyContext();
  gl.Enable(GL_BLEND);
  gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  static struct Window {
   public:
    ~this() {
      sfWindow_destroy(window_);
      ft.Dispose();
    }
    void Flush() {
      sfWindow_display(window_);
    }

    @property auto ptr() { return window_; }
    alias ptr this;

   private:
    ReturnType!sfWindow_create window_;
  }
  return Window(win);
}
