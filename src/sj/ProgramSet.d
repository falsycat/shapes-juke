/// License: MIT
module sj.ProgramSet;

import std.meta,
       std.typecons;

static import sjplayer = sjplayer.ProgramSet;

import sj.CubeProgram,
       sj.TextProgram,
       sj.TitleTextProgram;

///
class ProgramSet {
 public:
  alias Programs = Tuple!(
      CubeProgram,
      TextProgram,
      TitleTextProgram,
    );

  ///
  this() {
    player_ = new sjplayer.ProgramSet;
    foreach (ref p; programs_) {
      p = new typeof(p);
    }
  }
  ~this() {
    player_.destroy();
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
      return player_.Get!T;
    }
  }

  ///
  @property sjplayer.ProgramSet player() {
    return player_;
  }

 private:
  sjplayer.ProgramSet player_;

  Programs programs_;
}
