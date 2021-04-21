// License: MIT
module ft4d.Face;

import std.conv,
       std.exception,
       std.string,
       std.typecons;

import ft4d.ft;

/// RefCounted version of Face.
alias FaceRef = RefCounted!Face;

/// A wrapper type for freetype Face object.
///
/// Usually this is wrapped by RefCounted.
/// When it's default, empty() property returns true.
struct Face {
 public:
  @disable this(this);

  alias native this;

  /// Creates new face from the path.
  static FaceRef CreateFromPath(string path, int index = 0) {
    FT_Face f;
    FT_New_Face(ft.lib, path.toStringz, index.to!FT_Long, &f).
      EnforceFT();
    return FaceRef(f);
  }
  /// Creates new face from the buffer.
  static FaceRef CreateFromBuffer(in ubyte[] buf, int index = 0) {
    FT_Face f;
    FT_New_Memory_Face(ft.lib, buf.ptr, buf.length.to!FT_Long, index.to!FT_Long, &f).
      EnforceFT();
    return FaceRef(f);
  }

  ~this() {
    if (!empty) FT_Done_Face(native_).EnforceFT();
  }

  /// A move operator. RHS will be empty.
  ref Face opAssign(ref Face rhs) {
    if (&rhs != &this) {
      native_     = rhs.native_;
      rhs.native_ = null;
    }
    return this;
  }

  ///
  @property bool empty() const {
    return !native_;
  }
  /// You should not modify the pointer directly.
  @property inout(FT_Face) native() inout in (!empty) {
    return native_;
  }

 private:
  FT_Face native_;
}

/// A set of parameters for loading glyphs.
struct GlyphLoader {
 public:
  ///
  int pxWidth, pxHeight;
  ///
  dchar character;

  ///
  FT_Int32 flags = FT_LOAD_DEFAULT;

  /// Loads a glyph with the parameters this has.
  bool Load(ref FaceRef face) const
  in {
    assert(!face.empty);
    assert(pxWidth+pxHeight > 0 && pxWidth >= 0 && pxHeight >= 0);
  }
  do {
    const i = FT_Get_Char_Index(face, character.to!FT_ULong);
    if (i == 0) return false;

    FT_Set_Pixel_Sizes(face, pxWidth.to!FT_UInt, pxHeight.to!FT_UInt).EnforceFT();

    FT_Load_Glyph(face, i, flags).EnforceFT();
    return true;
  }
}

/// Throws an exception if the face doesn't have a rendered bitmap in its glyph slot.
///
/// Returns: the rendered bitmap in the glyph slot
ref const(FT_Bitmap) EnforceGlyphBitmap(in ref FaceRef face) in (!face.empty) {
  (face.glyph.format == FT_GLYPH_FORMAT_BITMAP).
    enforce("the glyph doesn't have bitmap");
  return face.glyph.bitmap;
}
