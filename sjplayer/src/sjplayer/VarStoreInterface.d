/// License: MIT
module sjplayer.VarStoreInterface;

import sjscript;

///
interface VarStoreInterface {
 public:
  ///
  float opIndex(string name) const;
}
