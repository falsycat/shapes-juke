/// License: MIT
module sj.Game;

import sj.AbstractGame,
       sj.FontSet,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this() {
    programs_ = new ProgramSet;
    fonts_    = new FontSet;

    lobby_ = new LobbyWorld(programs_);

    title_ = new TitleScene(lobby_, programs_);
    title_.SetupSceneDependency(title_);  // TODO: specify proper next scene

    super(title_);
  }

  ~this() {
    title_.destroy();

    lobby_.destroy();

    programs_.destroy();
    fonts_.destroy();
  }

 private:
  ProgramSet programs_;

  FontSet fonts_;

  LobbyWorld lobby_;

  TitleScene title_;
}
