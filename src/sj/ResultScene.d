/// License: MIT
module sj.ResultScene;

import std.conv,
       std.format,
       std.math,
       std.random;

import gl4d;

import sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.Text,
       sj.TextProgram,
       sj.TitleScene,
       sj.util.Animation,
       sj.util.Easing;

///
class ResultScene : SceneInterface {
 public:
  ///
  enum AnimationFrame = 60;

  ///
  enum CubeLoadingRotationSpeed = vec3(PI/100, PI/10, PI/100);
  ///
  enum CubeLoadingInterval = 0.06;
  ///
  enum BgLoadingInnerColor = vec4(0.4, 0.4, 0.4, 1);
  ///
  enum BgLoadingOuterColor = vec4(-0.2, -0.2, -0.2, 1);

  ///
  enum CubeRotationSpeed = vec3(PI/1000, PI/500, PI/1000);
  ///
  enum CubeInterval = 0.005;

  ///
  enum DescTextScale = vec3(-0.1, 0.1, 0.1);
  ///
  enum DescTextTranslation = vec3(0, -0.3, 0);
  ///
  enum DescTextColor = vec4(0.2, 0.2, 0.2, 1);
  ///
  enum RankTextScale = vec3(-0.1, 0.1, 0.1);
  ///
  enum RankTextTranslation = vec3(0, -0.5, 0);
  ///
  enum ScoreTextScale = vec3(-0.1, 0.1, 0.1);
  ///
  enum ScoreTextTranslation = vec3(0, -0.55, 0);

  ///
  enum RankCalculationRatio = 10000;

  ///
  this(LobbyWorld lobby, ProgramSet programs, FontSet fonts) {
    lobby_    = lobby;
    programs_ = programs;
    fonts_    = fonts;

    description_text_ = new Text(programs.Get!TextProgram);
    score_text_       = new Text(programs.Get!TextProgram);
    rank_text_        = new Text(programs.Get!TextProgram);

    with (description_text_) {
      const w = LoadGlyphs(vec2i(256, 32),
          "YOUR RANK", vec2i(16, 0), fonts_.gothic);
      matrix.scale       = DescTextScale;
      matrix.translation =
        DescTextTranslation + vec3(-w/2*matrix.scale.x, 0, 0);
      color = DescTextColor;
    }
  }
  ~this() {
    description_text_.destroy();
    score_text_.destroy();
    rank_text_.destroy();
  }

  ///
  void SetupSceneDependency(TitleScene title) {
    title_scene_ = title;
  }

  ///
  void Initialize(Music music, int score) {
    music_ = music;

    anime_ = Animation(AnimationFrame);

    cube_interval_ease_ =
      Easing!float(CubeLoadingInterval, CubeInterval);
    cube_rotation_speed_ease_ =
      Easing!vec3(CubeLoadingRotationSpeed, CubeRotationSpeed);

    bg_inner_ease_ =
      Easing!vec4(BgLoadingInnerColor, music_.preview.bg_inner_color);
    bg_outer_ease_ =
      Easing!vec4(BgLoadingOuterColor, music_.preview.bg_outer_color);

    with (score_text_) {
      auto w = LoadGlyphs(vec2i(512, 64),
          "%d pt".format(score).to!dstring, vec2i(16, 0), fonts_.gothic);
      matrix.scale       = ScoreTextScale;
      matrix.translation =
        ScoreTextTranslation + vec3(-w/2 * matrix.scale.x, 0, 0);
    }
    with (rank_text_) {
      auto w = LoadGlyphs(vec2i(512, 128),
          GetRankLetter(score), vec2i(100, 0), fonts_.gothic);
      matrix.scale       = RankTextScale;
      matrix.translation =
        RankTextTranslation + vec3(-w/2 * matrix.scale.x, 0, 0);
    }
  }
  override SceneInterface Update(KeyInput input) {
    const ratio = anime_.Update();

    with (lobby_) {
      cube_matrix.rotation += cube_rotation_speed_ease_.Calculate(ratio);
      cube_interval         = cube_interval_ease_      .Calculate(ratio);

      background.inner_color = bg_inner_ease_.Calculate(ratio);
      background.outer_color = bg_outer_ease_.Calculate(ratio);
    }
    if (anime_.isFinished && input.down) {
      title_scene_.Initialize();
      return title_scene_;
    }
    return this;
  }
  override void Draw() {
    const ratio = anime_.ratio;

    lobby_.Draw();

    const view = lobby_.view.Create();
    description_text_.Draw(lobby_.Projection, view);
    rank_text_       .Draw(lobby_.Projection, view);
    score_text_      .Draw(lobby_.Projection, view);
  }

 private:
  static dstring GetRankLetter(int score) {
    const ratio = score*1f / RankCalculationRatio;
    if (ratio < 0.60) return "D"d;
    if (ratio < 0.80) return "B"d;
    if (ratio < 0.95) return "A"d;
    return "S";
  }

  TitleScene title_scene_;

  LobbyWorld lobby_;

  ProgramSet programs_;

  FontSet fonts_;

  Music music_;

  Text description_text_;
  Text score_text_;
  Text rank_text_;

  Animation anime_;

  Easing!vec3  cube_rotation_speed_ease_;
  Easing!float cube_interval_ease_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
}
