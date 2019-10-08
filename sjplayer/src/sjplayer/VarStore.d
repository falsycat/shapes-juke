/// License: MIT
module sjplayer.VarStore;

import std.exception,
       std.format;

import sjplayer.Actor,
       sjplayer.VarStoreInterface;

///
class VarStore : VarStoreInterface {
 public:
  ///
  this(in Actor actor) {
    actor_ = actor;
  }

  override float opIndex(string name) const {
    switch (name) {
      case "actor_x": return actor_.pos.x;
      case "actor_y": return actor_.pos.y;

      default: throw new Exception("unknown variable %s".format(name));
    }
  }

 private:
  const Actor actor_;
}
