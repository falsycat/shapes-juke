/// License: MIT
module sj.Game;

import sj.AbstractGame,
       sj.TitleScene;

///
class Game : AbstractGame {
 public:
  ///
  this() {
    title_ = new TitleScene;
    title_.Initialize(title_);  // TODO: specify proper next scene

    super(title_);
  }

 private:
  TitleScene title_;
}
