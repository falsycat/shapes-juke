/// License: MIT
module sj.TitleScene;

import std.conv,
       std.math;

import gl4d;

import sjplayer;

import sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SelectScene,
       sj.SceneInterface,
       sj.TitleTextProgram,
       sj.util.Animation,
       sj.util.Easing;

///
class TitleScene : SceneInterface {
 public:
  ///
  enum TitleMatrix = {
    auto m = mat4.identity;
    m.scale(0.8, 0.1, 0.1);
    m.translate(0, -0.3, 0);
    return m;
  }();

  ///
  enum AnimationFrame = 30;
  ///
  enum BgInnerColor = vec4(0.9, 0.9, 0.9, 1);
  ///
  enum BgOuterColor = vec4(-0.1, -0.1, -0.1, 1);
  ///
  enum CubeInterval = 0.005;
  ///
  enum Contrast = vec4(1.2, 1.2, 1.2, 1);

  ///
  this(PostEffect posteffect, LobbyWorld lobby, sj.ProgramSet.ProgramSet program) {
    posteffect_ = posteffect;
    lobby_      = lobby;
    title_      = program.Get!TitleTextProgram;
  }

  ///
  void SetupSceneDependency(SelectScene select) {
    select_scene_ = select;
  }

  ///
  void Initialize() {
    anime_ = Animation(AnimationFrame);

    bg_inner_ease_ = Easing!vec4(lobby_.background.inner_color, BgInnerColor);
    bg_outer_ease_ = Easing!vec4(lobby_.background.outer_color, BgOuterColor);

    cube_interval_ease_ = Easing!float(lobby_.cube_interval, CubeInterval);

    contrast_ease_ = Easing!vec4(posteffect_.contrast, Contrast);
  }
  override SceneInterface Update(KeyInput input) {
    const ratio = anime_.Update();

    lobby_.cube_matrix.rotation += vec3(PI/600, PI/600, PI/600);

    lobby_.background.inner_color = bg_inner_ease_.Calculate(ratio);
    lobby_.background.outer_color = bg_outer_ease_.Calculate(ratio);

    lobby_.cube_interval = cube_interval_ease_.Calculate(ratio);

    posteffect_.contrast = contrast_ease_.Calculate(ratio);

    if (anime_.isFinished && input.down) {
      select_scene_.Initialize();
      return select_scene_;
    }
    return this;
  }
  override void Draw() {
    lobby_.Draw();
    title_.Draw(lobby_.Projection, lobby_.view.Create(), TitleMatrix,
        (anime_.frame%int.max).to!int);
  }

 private:
  SelectScene select_scene_;

  PostEffect posteffect_;

  LobbyWorld lobby_;

  TitleTextProgram title_;

  Animation anime_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
  Easing!float cube_interval_ease_;

  Easing!vec4 contrast_ease_;
}
