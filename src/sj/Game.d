/// License: MIT
module sj.Game;

import std.algorithm,
       std.exception,
       std.file,
       std.json,
       std.path;

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

    lobby_ = new LobbyWorld(programs_);

    title_  = new TitleScene(lobby_, programs_);
    select_ = new SelectScene(lobby_, programs_, fonts_, music_list_);
    load_   = new LoadingScene(args, lobby_, programs_, fonts_);
    play_   = new PlayScene;
    result_ = new ResultScene(lobby_, programs_, fonts_);

    title_ .SetupSceneDependency(select_);
    select_.SetupSceneDependency(title_, load_);
    load_  .SetupSceneDependency(play_);
    play_  .SetupSceneDependency(result_);
    result_.SetupSceneDependency(title_);

    if (args.debug_music_index >= 0) {
      enforce(args.debug_music_index < music_list.length);
      load_.Initialize(music_list_[args.debug_music_index]);
      super(load_);

    } else {
      title_.Initialize();
      super(title_);
    }
  }

  ~this() {
    title_.destroy();
    select_.destroy();
    load_.destroy();
    play_.destroy();
    result_.destroy();

    lobby_.destroy();

    fonts_.destroy();
    programs_.destroy();

    music_list_.each!destroy();
  }

 private:
  Music[] music_list_;

  FontSet    fonts_;
  ProgramSet programs_;

  LobbyWorld lobby_;

  TitleScene   title_;
  SelectScene  select_;
  LoadingScene load_;
  PlayScene    play_;
  ResultScene  result_;
}
