/// License: MIT
module sj.ResultScene;

import gl4d;

import sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SceneInterface;

///
class ResultScene : SceneInterface {
 public:
  ///
  this(LobbyWorld lobby, ProgramSet programs, FontSet fonts) {
    lobby_    = lobby;
    programs_ = programs;
    fonts_    = fonts;
  }
  ~this() {
  }

  ///
  void SetupSceneDependency() {
  }

  ///
  void Initialize(Music music, int score) {
    music_ = music;
  }
  override SceneInterface Update(KeyInput input) {
    return this;
  }
  override void Draw() {
    lobby_.Draw();
  }

 private:
  LobbyWorld lobby_;

  ProgramSet programs_;

  FontSet fonts_;

  Music music_;
}
