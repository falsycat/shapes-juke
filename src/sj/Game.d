/// License: MIT
module sj.Game;

import std.algorithm,
       std.file,
       std.json,
       std.path;

import sj.AbstractGame,
       sj.FontSet,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SelectScene,
       sj.Song,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this() {
    const path = thisExePath.dirName;

    const songs_dir  = buildPath(path, "songs");
    const songs_list = buildPath(songs_dir, "list.json").readText;
    songs_ = Song.CreateFromJson(songs_list.parseJSON, songs_dir);

    programs_ = new ProgramSet;
    fonts_    = new FontSet;

    lobby_ = new LobbyWorld(programs_);

    title_  = new TitleScene(lobby_, programs_);
    select_ = new SelectScene(lobby_, programs_, songs_);

    title_.SetupSceneDependency(select_);
    select_.SetupSceneDependency(title_);

    title_.Initialize();
    super(title_);
  }

  ~this() {
    title_.destroy();

    lobby_.destroy();

    programs_.destroy();
    fonts_.destroy();

    songs_.each!destroy();
  }

 private:
  Song[] songs_;

  ProgramSet programs_;

  FontSet fonts_;

  LobbyWorld lobby_;

  TitleScene title_;

  SelectScene select_;
}
