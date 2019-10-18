/// License: MIT
module sj.AbstractGame;

import gl4d;

import sj.KeyInput,
       sj.SceneInterface;

///
class AbstractGame {
 public:
  ///
  this(SceneInterface first_scene) in (first_scene) {
    scene_ = first_scene;
  }

  ///
  void Update(KeyInput input) {
    while (true) {
      auto next_scene = scene_.Update(input);
      if (next_scene is scene_) break;

      scene_ = next_scene;
    }
  }
  ///
  void Draw() {
    scene_.Draw();
  }

 private:
  SceneInterface scene_;
}
