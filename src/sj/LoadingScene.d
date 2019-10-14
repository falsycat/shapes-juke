/// License: MIT
module sj.LoadingScene;

import sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SceneInterface;

///
class LoadingScene : SceneInterface {
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
  void SetupSceneDependency() {  // TODO: add play scene
  }

  ///
  void Initialize(Music music) {
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
}
