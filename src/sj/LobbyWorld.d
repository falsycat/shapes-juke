/// License: MIT
module sj.LobbyWorld;

import sjplayer.Background;

import sj.ProgramSet;

///
class LobbyWorld {
 public:
  ///
  this(ProgramSet programs) {
    background_ = new Background(programs.forPlayers.Get!BackgroundProgram);
  }

  ///
  void Draw() {
    background_.Draw();
  }

  ///
  @property Background background() {
    return background_;
  }

 private:
  Background background_;
}
