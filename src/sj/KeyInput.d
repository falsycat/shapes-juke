/// License: MIT
module sj.KeyInput;

import std.typecons;

///
alias KeyInput = BitFlags!KeyInputType;

private enum KeyInputType {
  left  = 1 << 0,
  right = 1 << 1,
  up    = 1 << 2,
  down  = 1 << 3,
}
