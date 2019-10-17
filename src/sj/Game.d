/// License: MIT
module sj.Game;

import std.algorithm,
       std.exception,
       std.file,
       std.json,
       std.path,
       std.typecons;

import gl4d;

static import sjplayer;

import sj.AbstractGame,
       sj.Args,
       sj.FontSet,
       sj.LoadingScene,
       sj.LobbyWorld,
       sj.Music,
       sj.PlayScene,
       sj.ProgramSet,
       sj.ResultScene,
       sj.SelectScene,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this(in ref Args args) {
    const path = thisExePath.dirName;

    const music_dir  = buildPath(path, "music");
    const music_list = buildPath(music_dir, "list.json").readText;
    music_list_ = Music.CreateFromJson(music_list.parseJSON, music_dir);

    // To prevent working GC, all objects should be created at here.

    fonts_    = new FontSet;
    programs_ = new ProgramSet;

    posteffect_ = new sjplayer.PostEffect(
        programs_.Get!(sjplayer.PostEffectProgram),
        vec2i(args.window_size, args.window_size));

    lobby_ = new LobbyWorld(programs_);

    title_  = new TitleScene(posteffect_, lobby_, programs_);
    select_ = new SelectScene(lobby_, programs_, fonts_, music_list_);
    load_   = new LoadingScene(lobby_, posteffect_, programs_, fonts_);
    play_   = new PlayScene(posteffect_);
    result_ = new ResultScene(lobby_, programs_, fonts_);

    title_ .SetupSceneDependency(select_);
    select_.SetupSceneDependency(title_, load_);
    load_  .SetupSceneDependency(play_);
    play_  .SetupSceneDependency(result_);
    result_.SetupSceneDependency(title_);

    if (args.debug_music_index >= 0) {
      enforce(args.debug_music_index < music_list.length);
      load_.Initialize(
          music_list_[args.debug_music_index],
          args.debug_music_offset_beat,
          Yes.FastLoad);
      super(load_);

    } else {
      title_.Initialize();
      super(title_);
    }

    // setup OpenGL
    gl.Enable(GL_BLEND);
    gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    gl.Disable(GL_DEPTH_TEST);
  }

  ~this() {
    title_.destroy();
    select_.destroy();
    load_.destroy();
    play_.destroy();
    result_.destroy();

    lobby_.destroy();
    posteffect_.destroy();

    fonts_.destroy();
    programs_.destroy();

    music_list_.each!destroy();
  }

  override void Draw() {
    gl.Clear(GL_COLOR_BUFFER_BIT);

    posteffect_.BindFramebuffer();
    gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    super.Draw();
    posteffect_.UnbindFramebuffer();

    posteffect_.DrawFramebuffer();
  }

 private:
  Music[] music_list_;

  FontSet    fonts_;
  ProgramSet programs_;

  sjplayer.PostEffect posteffect_;
  LobbyWorld          lobby_;

  TitleScene   title_;
  SelectScene  select_;
  LoadingScene load_;
  PlayScene    play_;
  ResultScene  result_;
}
