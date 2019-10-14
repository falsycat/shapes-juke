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

      default:
    }
    return name in user_vars_?
      Nullable!float(user_vars_[name]): Nullable!float.init;
  }

  ///
  void opIndexAssign(float value, string name) {
    user_vars_[name] = value;
  }

 private:
  const Actor actor_;

  float[string] user_vars_;
}
