/// License: MIT
module sj.ResultScene;

import std.math;

import gl4d;

import sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SceneInterface,
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
  enum CubeRotationSpeed = vec3(PI/1000, PI/500, PI/1000);
  ///
  enum CubeInterval = 0.005;

  ///
  this(LobbyWorld lobby, ProgramSet programs, FontSet fonts) {
    lobby_    = lobby;
    programs_ = programs;
    fonts_    = fonts;
  }
  ~this() {
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
  }
  override SceneInterface Update(KeyInput input) {
    const ratio = anime_.Update();

    with (lobby_) {
      cube_matrix.rotation += cube_rotation_speed_ease_.Calculate(ratio);
      cube_interval         = cube_interval_ease_      .Calculate(ratio);
    }
    if (anime_.isFinished && input.down) {
      title_scene_.Initialize();
      return title_scene_;
    }
    return this;
  }
  override void Draw() {
    lobby_.Draw();
  }

 private:
  TitleScene title_scene_;

  LobbyWorld lobby_;

  ProgramSet programs_;

  FontSet fonts_;

  Music music_;

  Animation    anime_;
  Easing!vec3  cube_rotation_speed_ease_;
  Easing!float cube_interval_ease_;
}
