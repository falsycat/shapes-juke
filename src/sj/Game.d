/// License: MIT
module sj.Game;

import sj.AbstractGame,
       sj.FontSet,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SelectScene,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this() {
    programs_ = new ProgramSet;
    fonts_    = new FontSet;

    lobby_ = new LobbyWorld(programs_);

    title_  = new TitleScene(lobby_, programs_);
    select_ = new SelectScene(lobby_, programs_);

    title_.SetupSceneDependency(select_);
    select_.SetupSceneDependency(title_);

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

  SelectScene select_;
}
