/// License: MIT
module sj.TitleScene;

import std.conv,
       std.math;

import gl4d;

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
  this(LobbyWorld lobby, ProgramSet program) {
    lobby_ = lobby;
    title_ = program.Get!TitleTextProgram;

    lobby_.view.pos    = vec3(0, -0.15, -1);
    lobby_.view.target = vec3(0, -0.15, 0);
    lobby_.view.up     = vec3(0, 1, 0);

    lobby_.background.inner_color = BgInnerColor;
    lobby_.background.outer_color = BgOuterColor;

    lobby_.light_pos                    = vec3(0, 9, -1);
    lobby_.cube_material.diffuse_color  = vec3(0.1, 0.1, 0.1);
    lobby_.cube_material.light_color    = vec3(1, 0.8, 0.8);
    lobby_.cube_material.light_power    = vec3(100, 100, 100);
    lobby_.cube_material.ambient_color  = vec3(0.2, 0.2, 0.2);
    lobby_.cube_material.specular_color = vec3(0.5, 0.2, 0.2);

    lobby_.cube_interval = CubeInterval;
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
  }
  override SceneInterface Update(KeyInput input) {
    const ratio = anime_.Update();

    lobby_.cube_matrix.rotation += vec3(PI/600, PI/600, PI/600);

    lobby_.background.inner_color = bg_inner_ease_.Calculate(ratio);
    lobby_.background.outer_color = bg_outer_ease_.Calculate(ratio);

    lobby_.cube_interval = cube_interval_ease_.Calculate(ratio);

    if (input.down) {
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

  LobbyWorld lobby_;

  TitleTextProgram title_;

  Animation anime_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
  Easing!float cube_interval_ease_;
}
