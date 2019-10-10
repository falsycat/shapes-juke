/// License: MIT
module sj.AbstractScene;

import sj.KeyInput,
       sj.SceneInterface;

///
class AbstractScene : SceneInterface {
 public:
  ///
  this() {
  }

  abstract override {
    void Update(KeyInput input);
    void Draw();
  }

  override SceneInterface TakeNextScene() {
    return next_;
  }

 protected:
  void GoNextScene(SceneInterface next) in (next) {
    next_ = next;
  }

 private:
  SceneInterface next_;
}
