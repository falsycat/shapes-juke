/// License: MIT
module sj.LoadingScene;

import std.math,
       std.typecons;

import gl4d;

static import sjplayer;

import sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.PlayScene,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.Text,
       sj.TextProgram,
       sj.util.Animation,
       sj.util.Easing;

///
class LoadingScene : SceneInterface {
 public:
  ///
  enum AnimeFrames = 300;
  ///
  enum FastLoadAnimeFrames = 30;
  ///
  enum CubeRotationSpeed = vec3(PI/200, PI/20, PI/200);
  ///
  enum LoadingTextScale = vec3(-0.1, 0.1, 0.1);
  ///
  enum LoadingTextTranslation = vec3(0, -0.3, 0);
  ///
  enum LoadingTextColor = vec4(0.2, 0.2, 0.2, 1);

  ///
  this(
      LobbyWorld          lobby,
      sjplayer.PostEffect posteffect,
      ProgramSet          programs,
      FontSet             fonts) {
    lobby_      = lobby;
    posteffect_ = posteffect;
    programs_   = programs;

    loading_text_ = new Text(programs.Get!TextProgram);
    with (loading_text_) {
      auto w = LoadGlyphs(
          vec2i(128, 32), "Loading...", vec2i(16, 0), fonts.gothic);
      matrix.scale = LoadingTextScale;
      matrix.translation =
        LoadingTextTranslation + vec3(-w/2*matrix.scale.x, 0, 0);
      color = LoadingTextColor;
    }
  }
  ~this() {
    loading_text_.destroy();
  }

  ///
  void SetupSceneDependency(PlayScene play) {
    play_scene_ = play;
  }

  ///
  void Initialize(Music music, float offset_beat, Flag!"FastLoad" fastload) {
    music_       = music;
    offset_beat_ = offset_beat;

    anime_ = Animation(fastload? FastLoadAnimeFrames: AnimeFrames);

    with (lobby_) {
      bg_inner_ease_ = Easing!vec4(
          music.preview.bg_inner_color, background.inner_color/2);
      bg_outer_ease_ = Easing!vec4(
          music.preview.bg_outer_color, background.outer_color/2);
    }
  }
  override SceneInterface Update(KeyInput input) {
    const ratio = anime_.Update();

    with (lobby_) {
      cube_matrix.rotation += CubeRotationSpeed;

      background.inner_color = bg_inner_ease_.Calculate(ratio);
      background.outer_color = bg_outer_ease_.Calculate(ratio);
    }

    posteffect_.clip_lefttop.y     = 1-pow(1-ratio, 4);
    posteffect_.clip_rightbottom.y = 1-pow(1-ratio, 4);

    if (anime_.isFinished) {
      // TODO: parallelize context creation
      auto context = music_.CreatePlayerContext(posteffect_, programs_.player);
      play_scene_.Initialize(music_, context, offset_beat_);
      return play_scene_;
    }
    return this;
  }
  override void Draw() {
    lobby_.Draw();
    loading_text_.Draw(lobby_.Projection, lobby_.view.Create());
  }

 private:
  sjplayer.PostEffect posteffect_;

  ProgramSet programs_;

  LobbyWorld lobby_;

  Text loading_text_;

  PlayScene play_scene_;

  Music music_;
  float offset_beat_;

  Animation anime_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
}
