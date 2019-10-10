/// License: MIT
module sjplayer.VarStore;

import std.exception,
       std.format,
       std.typecons;

import sjplayer.Actor,
       sjplayer.VarStoreInterface;

///
class VarStore : VarStoreInterface {
 public:
  ///
  this(in Actor actor) {
    actor_ = actor;
  }

  override Nullable!float opIndex(string name) const {
    switch (name) {
      case "actor_x": return Nullable!float(actor_.pos.x);
      case "actor_y": return Nullable!float(actor_.pos.y);

      default: return Nullable!float.init;
    }
  }

 private:
  const Actor actor_;
}
