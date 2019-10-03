/// License: MIT
module sjscript.preprocess;

import std.algorithm,
       std.array,
       std.conv,
       std.exception,
       std.range,
       std.range.primitives,
       std.typecons;

import sjscript.Token;

///
unittest {
  import std;
  import dast.tokenize;

  auto Tokenize(string src) {
    return src.
      Tokenize!TokenType().
      filter!(x => x.type != TokenType.Whitespace).
      Preprocess().
      map!"a.text";
  }

  {
    enum src = q"EOS
      $define temp1 { $temp2 }
      $define temp2 { hoge }

      $temp1 $temp2
EOS";
    assert(Tokenize(src).equal(["hoge", "hoge"]));
  }
  {
    enum src = q"EOS
      $repeat i 3 {
        $repeat j 3 { $j }
      }
EOS";
    assert(Tokenize(src).equal(["0", "1", "2"].cycle().take(9)));
  }
}

///
auto Preprocess(R)(R tokenizer) {
  auto p = Preprocessor!R(tokenizer);
  p.Preprocess();
  return p;
}

private struct Preprocessor(R)
  if (isInputRange!R && is(ElementType!R == Token)) {
 public:
  ///
  @property bool empty() {
    return status_.length == 0 && tokens_.empty;
  }
  ///
  @property Token front() in (!empty) {
    if (status_.length == 0) {
      return tokens_.front;
    }
    const status = status_[$-1];
    return status.tokens[status.index];
  }
  ///
  void popFront() in (!empty) {
    PopFrontWithoutPreprocess();
    Preprocess();
  }

 private:
  static struct ExpansionState {
   public:
    size_t  index;
    Token[] tokens;

    size_t counter_max;
    size_t counter;

    string name;
    string counter_name;
  }

  void PopStatus() {
    if (status_.length == 0) return;
    auto status = &status_[$-1];
    if (++status.index >= status.tokens.length) {
      status.index = 0;
      if (++status.counter >= status.counter_max) {
        status_ = status_[0..$-1];
        PopStatus();
      }
    }
  }
  void PopFrontWithoutPreprocess() in (!empty) {
    PopStatus();
    if (status_.length == 0) {
      return tokens_.popFront();
    }
  }
  Token[] PopFrontBlockWithoutPreprocess()
      in (!empty && front.type == TokenType.OpenBrace) {
    auto result = appender!(Token[]);

    size_t nest;
    while (true) {
      const front = front;
      if (front.type == TokenType.OpenBrace)  ++nest;
      if (front.type == TokenType.CloseBrace) --nest;
      result ~= front;

      if (nest == 0) break;
      PopFrontWithoutPreprocess();
      (!empty).enforce();
    }
    (result[].length >= 2).enforce();
    return result[][1..$-1];
  }

  void Preprocess() {
    if (empty || front.type != TokenType.PreprocessCommand) {
      return;
    }

    switch (front.text) {
      case "$define":
        DefineTemplate();
        break;
      case "$repeat":
        ExpandRepeat();
        break;
      default:
        ExpandTemplate();
        break;
    }
    Preprocess();
  }
  void DefineTemplate() {
    PopFrontWithoutPreprocess();
    (!empty).enforce();

    const name = front;
    (name.type == TokenType.Ident).enforce();
    PopFrontWithoutPreprocess();
    (!empty).enforce();

    (front.type == TokenType.OpenBrace).enforce();
    templates_[name.text] = PopFrontBlockWithoutPreprocess();
    PopFrontWithoutPreprocess();
  }
  void ExpandRepeat() {
    PopFrontWithoutPreprocess();
    (!empty).enforce();

    string counter_name;
    if (front.type == TokenType.Ident) {
      counter_name = front.text;
      PopFrontWithoutPreprocess();
      (!empty).enforce();
    }
    if (counter_name != "") {
      (!status_.map!"a.counter_name".canFind(counter_name)).enforce();
      (!templates_.keys.canFind(counter_name)).enforce();
    }

    (front.type == TokenType.Number).enforce();
    const count = front.text.to!float.to!int;
    PopFrontWithoutPreprocess();
    (!empty).enforce();

    (front.type == TokenType.OpenBrace).enforce();
    ExpansionState state;
    state.tokens       = PopFrontBlockWithoutPreprocess();
    state.counter_max  = count.to!size_t;
    state.counter_name = counter_name;

    if (state.counter_max == 0 || state.tokens.length == 0) return;
    status_ ~= state;
  }
  void ExpandTemplate() {
    const name = front.text[1..$];
    (name != "").enforce();
    (!status_.map!"a.name".canFind(name)).enforce();

    Token[] body;
    const counter = GetCounterValue(name);
    if (counter.isNull) {
      (name in templates_).enforce();
      body = templates_[name];
    } else {
      body = [Token(counter.get.to!string, TokenType.Number)];
    }

    ExpansionState state;
    state.tokens      = body;
    state.counter_max = 1;
    state.name        = name;

    if (state.tokens.length == 0) return;
    status_ ~= state;
  }

  Nullable!size_t GetCounterValue(string name) {
    auto found_states = status_.retro.find!"a.counter_name == b"(name);
    if (found_states.empty) return Nullable!size_t.init;
    return found_states.front.counter.nullable;
  }

  R tokens_;

  Token[][string] templates_;

  ExpansionState[] status_;
}
