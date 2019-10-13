/// License: MIT
module sj.SceneInterface;

import sj.KeyInput;

///
interface SceneInterface {
 public:
  ///
  SceneInterface Update(KeyInput input);
  ///
  void Draw();
}
