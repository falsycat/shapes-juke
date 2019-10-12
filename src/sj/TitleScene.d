/// License: MIT
module sj.TitleScene;

import std.math;

import gl4d;

import sj.AbstractScene,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.TitleTextProgram;

///
class TitleScene : AbstractScene {
 public:
  ///
  enum TitleMatrix = {
    auto m = mat4.identity;
    m.scale(0.8, 0.1, 0.1);
    m.translate(0, -0.3, 0);
    return m;
  }();

  ///
  this(LobbyWorld lobby, ProgramSet program) {
    lobby_ = lobby;
    SetupLobby(lobby);

    title_ = program.Get!TitleTextProgram;
  }

  ///
  void SetupSceneDependency(SceneInterface next_scene) {
    next_scene_ = next_scene;
  }

  override void Update(KeyInput input) {
    lobby_.cube_matrix.rotation += vec3(PI/600, PI/600, PI/600);

    if (input.down) GoNextScene(next_scene_);
  }
  override void Draw() {
    lobby_.Draw();
    title_.Draw(lobby_.Projection, lobby_.view.Create(), TitleMatrix, frame_++);
  }

 private:
  static void SetupLobby(LobbyWorld lobby) {
    lobby.view.pos    = vec3(0, -0.15, -1);
    lobby.view.target = vec3(0, -0.15, 0);
    lobby.view.up     = vec3(0, 1, 0);

    lobby.background.inner_color = vec4(0.9, 0.9, 0.9, 1);
    lobby.background.outer_color = vec4(-0.1, -0.1, -0.1, 1);

    lobby.light_pos                    = vec3(0, 9, -1);
    lobby.cube_material.diffuse_color  = vec3(0.1, 0.1, 0.1);
    lobby.cube_material.light_color    = vec3(1, 0.8, 0.8);
    lobby.cube_material.light_power    = vec3(100, 100, 100);
    lobby.cube_material.ambient_color  = vec3(0.2, 0.2, 0.2);
    lobby.cube_material.specular_color = vec3(0.5, 0.2, 0.2);
  }

  SceneInterface next_scene_;

  LobbyWorld lobby_;

  TitleTextProgram title_;

  int frame_;
}
