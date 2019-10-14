/// License: MIT
module sj.LoadingScene;

import gl4d;

import sj.Args,
       sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.PlayScene,
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
  void SetupSceneDependency(PlayScene play) {  // TODO: add play scene
    play_scene_ = play;
  }

  ///
  void Initialize(Music music) {
    music_ = music;

    first_drawn_ = false;
  }
  override SceneInterface Update(KeyInput input) {
    if (first_drawn_) {
      // TODO: parallelize contex creation
      auto context = music_.CreatePlayerContext(
          vec2i(args_.window_size, args_.window_size), programs_.player);
      play_scene_.Initialize(music_, context);
      return play_scene_;
    }
    return this;
  }
  override void Draw() {
    lobby_.Draw();
    first_drawn_ = true;
  }

 private:
  const Args args_;

  PlayScene play_scene_;

  ProgramSet programs_;

  FontSet fonts_;

  LobbyWorld lobby_;

  Music music_;

  bool first_drawn_;
}
