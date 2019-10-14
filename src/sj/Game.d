/// License: MIT
module sj.Game;

import std.algorithm,
       std.file,
       std.json,
       std.path;

import sj.AbstractGame,
       sj.FontSet,
       sj.LoadingScene,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SelectScene,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this() {
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
    load_   = new LoadingScene(lobby_, programs_, fonts_);

    title_ .SetupSceneDependency(select_);
    select_.SetupSceneDependency(title_, load_);
    load_  .SetupSceneDependency();  // TODO: pass play scene

    title_.Initialize();
    super(title_);
  }

  ~this() {
    title_.destroy();
    select_.destroy();
    load_.destroy();

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
}
