/// License: MIT
module sj.Song;

import std.array,
       std.conv,
       std.exception,
       std.json,
       std.path,
       std.string;

import derelict.sfml2.audio,
       derelict.sfml2.system;

import gl4d;

static import sjplayer;

///
class Song {
 public:
  ///
  static struct PreviewConfig {
   public:
    ///
    size_t play_offset;

    ///
    vec4 bg_inner_color = vec4(0, 0, 0, 0);
    ///
    vec4 bg_outer_color = vec4(0, 0, 0, 0);
  }

  ///
  static Song[] CreateFromJson(in JSONValue json, string basepath) {
    auto result = appender!(Song[]);
    result.reserve(json.array.length);

    foreach (item; json.array) {
      result ~= new Song(item, basepath);
    }
    return result[];
  }

  ///
  this(in JSONValue json, string basepath) {
    const music_path = buildPath(basepath, json["music"].str);

    name_        = json["name"].str;
    bpm_         = GetNumericAsFloatFromJson(json["bpm"]);
    music_       = sfMusic_createFromFile(music_path.toStringz).enforce;
    script_path_ = buildPath(basepath, json["script"].str);

    with (preview_) {
      const preview_json = json["preview"];

      play_offset    = preview_json["play-offset"].integer;
      bg_inner_color = GetVectorFromJson!4(preview_json["bg-inner-color"]);
      bg_outer_color = GetVectorFromJson!4(preview_json["bg-outer-color"]);
    }
  }
  ~this() {
    sfMusic_destroy(music_);
  }

  ///
  void PlayForGame() {
    sfMusic_setPlayingOffset(music_, sfMilliseconds(0));
    sfMusic_play(music_);
  }
  ///
  void PlayForPreview() {
    sfMusic_setPlayingOffset(
        music_, sfMilliseconds(preview_.play_offset.to!int));
    sfMusic_play(music_);
  }

  ///
  void StopPlaying() {
    sfMusic_stop(music_);
  }

  ///
  sjplayer.Context CreatePlayerContext() const {
    assert(false);  // TODO:
  }

  ///
  @property ref const(PreviewConfig) preview() const {
    return preview_;
  }

 private:
  static float GetNumericAsFloatFromJson(in JSONValue json) {
    return json.type == JSONType.float_? json.floating: json.integer;
  }
  static Vector!(float, dim) GetVectorFromJson(size_t dim)(in JSONValue json) {
    (json.array.length == dim).enforce;

    Vector!(float, dim) v;
    static foreach (i; 0..dim) {
      v.vector[i] = GetNumericAsFloatFromJson(json.array[i]);
    }
    return v;
  }

  string name_;

  float bpm_;

  sfMusic* music_;

  string script_path_;

  PreviewConfig preview_;
}
