/// License: MIT
module sj.SceneInterface;

import sj.KeyInput;

///
interface SceneInterface {
 public:
  ///
  void Update(KeyInput input);
  ///
  void Draw();

  ///
  SceneInterface TakeNextScene();
}
