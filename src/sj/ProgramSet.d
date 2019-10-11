/// License: MIT
module sj.ProgramSet;

import std.meta,
       std.typecons;

static import sjplayer = sjplayer.ProgramSet;

import sj.CubeProgram;

///
class ProgramSet {
 public:
  alias Programs = Tuple!(
      CubeProgram,
    );

  ///
  this() {
    for_player_ = new sjplayer.ProgramSet;
    foreach (ref p; programs_) {
      p = new typeof(p);
    }
  }
  ~this() {
    for_player_.destroy();
    foreach (p; programs_) {
      p.destroy();
    }
  }

  ///
  T Get(T)() {
    enum index = staticIndexOf!(T, Programs.Types);
    static if (index >= 0) {
      return programs_[index];
    } else {
      return for_player_.Get!T;
    }
  }

 private:
  sjplayer.ProgramSet for_player_;

  Programs programs_;
}
