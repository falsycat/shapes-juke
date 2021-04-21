/// License: MIT
module dast.tokenize.match;

import std.algorithm,
       std.ascii,
       std.conv,
       std.traits;

///
unittest {
  import std;

  enum TokenType {
    @TextAllMatcher!isDigit  Number,
    @TextCompleteMatcher!"12" OneTwo,

    @TextFuncMatcher!((string text) {
      return text.length >= 3? 3LU: 0LU;
    }) ThreeLetters,

    @TextAllMatcher!isUpper
    @TextAllMatcher!isLower Ident,
  }

  with (TokenType) {
    assert(MatchTextAsTokenType!Number("0123")  == 4);
    assert(MatchTextAsTokenType!Number("01a23") == 2);
    assert(MatchTextAsTokenType!Number("a0123") == 0);

    assert(MatchTextAsTokenType!OneTwo("12")  == 2);
    assert(MatchTextAsTokenType!OneTwo("12a") == 2);
    assert(MatchTextAsTokenType!OneTwo("1")   == 0);

    assert(MatchTextAsTokenType!ThreeLetters("abc")  == 3);
    assert(MatchTextAsTokenType!ThreeLetters("abcd") == 3);
    assert(MatchTextAsTokenType!ThreeLetters("ab")   == 0);

    assert(MatchTextAsTokenType!Ident("abC") == 2);
    assert(MatchTextAsTokenType!Ident("AB0") == 2);
    assert(MatchTextAsTokenType!Ident("0Ab") == 0);

    {
      const result = FindMatchedTokenTypes!TokenType("012");
      assert(result.types.equal([Number, ThreeLetters]));
      assert(result.length == 3);
    }
    {
      const result = FindMatchedTokenTypes!TokenType("12");
      assert(result.types.equal([Number, OneTwo]));
      assert(result.length == 2);
    }
  }
}

/// Checks if the matcher is a text matcher for S.
enum IsTextMatcher(alias matcher, S) =
  __traits(compiles, (S str) => matcher.Match(str)) &&
  is(ReturnType!((S str) => matcher.Match(str)) == size_t);
/// ditto
enum IsTextMatcher(alias matcher) =
  IsTextMatcher!(matcher,  string) ||
  IsTextMatcher!(matcher, wstring) ||
  IsTextMatcher!(matcher, dstring);

///
struct TextAllMatcher(alias func) {
 public:
  ///
  static size_t Match(S)(S text) if (isSomeString!S) {
    const index = text.countUntil!(x => !func(x));
    return index >= 0? index.to!size_t: text.length;
  }
  static assert(IsTextMatcher!TextAllMatcher);
}

///
struct TextCompleteMatcher(alias str) if (isSomeString!(typeof(str))) {
 public:
  ///
  static size_t Match(typeof(str) text) {
    if (text.length < str.length || text[0..str.length] != str) {
      return 0;
    }
    return str.length;
  }
  static assert(IsTextMatcher!TextCompleteMatcher);
}

///
struct TextFuncMatcher(alias func)
  if ((is(typeof((string  x) => func(x))) ||
       is(typeof((wstring x) => func(x))) ||
       is(typeof((dstring x) => func(x)))) &&
      is(ReturnType!func == size_t)) {
 public:
  ///
  static size_t Match(S)(S text)
      if (isSomeString!S && __traits(compiles, func(text))) {
    return func(text);
  }
  static assert(IsTextMatcher!(TextFuncMatcher, string));
}

/// Finds matched token types from TokenType enum.
auto FindMatchedTokenTypes(TokenType, S)(S src)
    if (is(TokenType == enum) && isSomeString!S) {
  struct Result {
    TokenType[] types;
    size_t      length;
  }
  Result result;

  size_t length = void;
  static foreach (type; EnumMembers!TokenType) {
    length = MatchTextAsTokenType!type(src);
    if (length == 0) {

    } else if (length > result.length) {
      result.types  = [type];
      result.length = length;

    } else if (length == result.length) {
      result.types ~= type;
    }
  }
  return result;
}

/// Checks if the src can be a token with the type.
size_t MatchTextAsTokenType(alias type, S)(S src)
    if (is(typeof(type) == enum) && isSomeString!S) {
  alias TokenType = typeof(type);
  enum  typestr   = "TokenType." ~ type.to!string;

  size_t result;
  static foreach (attr; __traits(getAttributes, mixin(typestr))) {
    static if (IsTextMatcher!(attr, S)) {
      result = result.max(attr.Match(src));
    }
  }
  return result;
}
