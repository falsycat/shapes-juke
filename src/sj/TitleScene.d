/// License: MIT
module sj.TitleScene;

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

    // TODO: test
    import gl4d;
    lobby_.background.outer_color = vec4(0.8, 0.8, 0.8, 1);
    lobby_.background.inner_color = vec4(1, 1, 1, 1);
  }

  ///
  void SetupSceneDependency(SceneInterface next_scene) {
    next_scene_ = next_scene;
  }

  override void Update(KeyInput input) {
  }
  override void Draw() {
    lobby_.Draw();
  }

 private:
  SceneInterface next_scene_;

  LobbyWorld lobby_;
}
