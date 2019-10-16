/// License: MIT
module sj.LoadingScene;

import gl4d;

static import sjplayer;

import sj.FontSet,
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
      LobbyWorld          lobby,
      sjplayer.PostEffect posteffect,
      ProgramSet          programs,
      FontSet             fonts) {
    lobby_      = lobby;
    posteffect_ = posteffect;
    programs_   = programs;
    fonts_      = fonts;
  }
  ~this() {
  }

  ///
  void SetupSceneDependency(PlayScene play) {  // TODO: add play scene
    play_scene_ = play;
  }

  ///
  void Initialize(Music music, float offset_beat) {
    music_       = music;
    offset_beat_ = offset_beat;

    first_drawn_ = false;
  }
  override SceneInterface Update(KeyInput input) {
    if (first_drawn_) {
      // TODO: parallelize context creation
      auto context = music_.CreatePlayerContext(posteffect_, programs_.player);
      play_scene_.Initialize(music_, context, offset_beat_);
      return play_scene_;
    }
    return this;
  }
  override void Draw() {
    lobby_.Draw();
    first_drawn_ = true;
  }

 private:
  sjplayer.PostEffect posteffect_;

  ProgramSet programs_;

  FontSet fonts_;

  LobbyWorld lobby_;

  PlayScene play_scene_;

  Music music_;
  float offset_beat_;

  bool first_drawn_;
}
