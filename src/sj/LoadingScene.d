/// License: MIT
module sj.LoadingScene;

import gl4d;

import sj.Args,
       sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SceneInterface;

///
class LoadingScene : SceneInterface {
 public:
  ///
  this(
      in ref Args args,
      LobbyWorld  lobby,
      ProgramSet  programs,
      FontSet     fonts) {
    args_     = args;
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
    music_ = music;

    first_drawn_ = false;
  }
  override SceneInterface Update(KeyInput input) {
    if (first_drawn_) {
      // TODO: parallelize contex creation
      // auto context = music_.CreatePlayerContext(
      //     vec2i(args_.window_size, args_.window_size), programs_.player);
      // TODO: pass the context to play scene
    }
    return this;
  }
  override void Draw() {
    lobby_.Draw();
    first_drawn_ = true;
  }

 private:
  const Args args_;

  LobbyWorld lobby_;

  ProgramSet programs_;

  FontSet fonts_;

  Music music_;

  bool first_drawn_;
}
