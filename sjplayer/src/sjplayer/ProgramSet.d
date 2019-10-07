/// License: MIT
module sjplayer.ProgramSet;

import std.meta,
       std.typecons;

import sjplayer.CircleElement;

///
class ProgramSet {
 public:
  ///
  alias Programs = Tuple!(CircleElementProgram);

  ///
  this() {
    foreach (ref program; programs_) {
      program = new typeof(program);
    }
  }
  ~this() {
    foreach (program; programs_) {
      program.destroy();
    }
  }

  ///
  T Get(T)() out (r; r) {
    enum index = staticIndexOf!(T, Programs.Types);
    static assert(index >= 0);
    return programs_[index];
  }

 private:
  Programs programs_;
}
