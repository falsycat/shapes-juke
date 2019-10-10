/// License: MIT
module sj.TitleScene;

import sj.AbstractScene,
       sj.KeyInput,
       sj.SceneInterface;

///
class TitleScene : AbstractScene {
 public:
  ///
  this() {
  }

  ///
  void Initialize(SceneInterface next_scene) {
    next_scene_ = next_scene;
  }

  override void Update(KeyInput input) {
  }
  override void Draw() {
  }

 private:
  SceneInterface next_scene_;
}
