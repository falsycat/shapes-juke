/// License: MIT
module sj.Game;

import sj.AbstractGame,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this() {
    programs_ = new ProgramSet;

    lobby_ = new LobbyWorld(programs_);

    title_ = new TitleScene(lobby_);
    title_.SetupSceneDependency(title_);  // TODO: specify proper next scene

    super(title_);
  }

  ~this() {
    title_.destroy();

    lobby_.destroy();

    programs_.destroy();
  }

 private:
  ProgramSet programs_;

  LobbyWorld lobby_;

  TitleScene title_;
}
