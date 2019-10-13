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
    next_scene_ = first_scene;
  }

  ///
  void Update(KeyInput input) {
    scene_      = next_scene_;
    next_scene_ = scene_.Update(input);
  }
  ///
  void Draw() {
    gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scene_.Draw();
  }

 private:
  SceneInterface scene_;

  SceneInterface next_scene_;
}
