/// License: MIT
module sjplayer.ActorControllerInterface;

import gl4d;

///
interface ActorControllerInterface {
 public:
  ///
  void Accelarate(vec2 accel);

  ///
  void Update();
}
