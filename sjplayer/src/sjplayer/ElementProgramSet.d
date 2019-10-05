/// License: MIT
module sjplayer.ElementProgramSet;

import std.meta,
       std.typecons;

import sjplayer.CircleElement;

///
class ElementProgramSet {
 public:
  ///
  alias ElementPrograms = Tuple!(CircleElementProgram);

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
    enum index = staticIndexOf!(T, ElementPrograms.Types);
    static assert(index >= 0);
    return programs_[index];
  }

 private:
  ElementPrograms programs_;
}
