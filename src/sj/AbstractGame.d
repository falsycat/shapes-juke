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
    if (auto next = scene_.TakeNextScene()) {
      scene_ = next;
    }
    scene_.Update(input);
  }
  ///
  void Draw() {
    gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scene_.Draw();
  }

 private:
  SceneInterface scene_;
}
