/// License: MIT
module dast.util.range;

import std.algorithm,
       std.array,
       std.range.primitives;

/// Returns: an input range which has unique items
auto DropDuplicated(R)(R src) if (isInputRange!R) {
  auto dest = appender!(ElementType!R[]);
  dest.reserve(src.length);

  foreach (item; src) if (!dest[].canFind(item)) dest ~= item;
  return dest[];
}
///
unittest {
  static assert([0, 1, 0, 1].DropDuplicated.equal([0, 1]));
}
