/// License: MIT
module sjplayer.VarStoreInterface;

import std.typecons;

import sjscript;

///
interface VarStoreInterface {
 public:
  ///
  Nullable!float opIndex(string name) const;
}
