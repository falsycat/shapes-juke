/// License: MIT
module sj.TitleScene;

import std.math;

import gl4d;

import sj.AbstractScene,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.SceneInterface;

///
class TitleScene : AbstractScene {
 public:
  ///
  this(LobbyWorld lobby) {
    lobby_ = lobby;
    SetupLobby(lobby);
  }

  ///
  void SetupSceneDependency(SceneInterface next_scene) {
    next_scene_ = next_scene;
  }

  override void Update(KeyInput input) {
    lobby_.cube_matrix.rotation += vec3(PI/300, PI/300, PI/300);
  }
  override void Draw() {
    lobby_.Draw();
  }

 private:
  static void SetupLobby(LobbyWorld lobby) {
    lobby.view.pos    = vec3(0, 0, -1);
    lobby.view.target = vec3(0, -0.2, 0);

    lobby.background.inner_color = vec4(0.9, 0.9, 0.9, 1);
    lobby.background.outer_color = vec4(0.2, 0.2, 0.2, 1);

    lobby.light_pos                    = vec3(0, 10, 0);
    lobby.cube_material.diffuse_color  = vec3(0.1, 0.1, 0.1);
    lobby.cube_material.light_color    = vec3(1, 0.8, 0.8);
    lobby.cube_material.light_power    = vec3(100, 100, 100);
    lobby.cube_material.ambient_color  = vec3(0.1, 0.1, 0.1);
    lobby.cube_material.specular_color = vec3(0.5, 0.2, 0.2);
  }

  SceneInterface next_scene_;

  LobbyWorld lobby_;
}
