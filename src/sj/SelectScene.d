/// License: MIT
module sj.SelectScene;

import std.conv,
       std.math,
       std.random,
       std.variant;

import derelict.sfml2.audio;

import gl4d;

import sj.FontSet,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.Song,
       sj.Text,
       sj.TextProgram,
       sj.TitleScene,
       sj.util.Animation,
       sj.util.Easing,
       sj.util.audio;

///
class SelectScene : SceneInterface {
 public:
  ///
  this(LobbyWorld lobby, ProgramSet program, FontSet fonts, Song[] songs) {
    lobby_ = lobby;
    songs_ = songs.dup;

    text_  = new Text(program.Get!TextProgram);
    fonts_ = fonts;

    sound_ = sfSound_create();
    soundres_.Load();

    first_state_ = new FirstSetupState(this);
    status_      = first_state_;
  }
  ~this() {
    text_.destroy();

    sfSound_destroy(sound_);
    soundres_.Unload();
  }

  ///
  void SetupSceneDependency(TitleScene title_scene) {
    title_scene_ = title_scene;
  }

  ///
  void Initialize() {
    first_state_.Initialize();
    status_ = first_state_;
  }
  override SceneInterface Update(KeyInput input) {
    SceneInterface     next_scene = this;
    AbstractSceneState next_state;

    status_.Update(input).visit!(
        (SceneInterface     scene) { next_scene = scene; },
        (AbstractSceneState state) { next_state = state; }
      );
    status_ = next_state;
    return next_scene;
  }
  override void Draw() {
    lobby_.Draw();
    text_.Draw(lobby_.Projection, lobby_.view.Create());
  }

 private:
  static struct SoundResources {
   public:
    enum Spotlight = cast(ubyte[]) import("sounds/spotlight.wav");

    sfSoundBuffer* spotlight;

    void Load() {
      spotlight = CreateSoundBufferFromBuffer(Spotlight);
    }
    void Unload() {
      sfSoundBuffer_destroy(spotlight);
    }
  }

  TitleScene title_scene_;

  LobbyWorld lobby_;

  Text    text_;
  FontSet fonts_;

  Song[] songs_;

  sfSound*       sound_;
  SoundResources soundres_;

  FirstSetupState    first_state_;
  AbstractSceneState status_;
}

private abstract class AbstractSceneState {
 public:
  alias UpdateResult = Algebraic!(AbstractSceneState, SceneInterface);

  enum CubeRotationSpeed = vec3(0, PI/500, 0);
  enum CubeInterval      = 0.005;

  enum LoadingCubeRotationSpeed = vec3(0, PI/5, PI/10);
  enum LoadingCubeInterval      = 0.06;

  enum TitleTextSize        = 40;
  enum TitleTextScale       = vec3(-0.002, 0.002, 0.002);
  enum TitleTextTranslation = vec3(0, -0.4, 0);

  enum TitleTextRandomTranslationRange = 0.02;
  enum TitleTextRandomScaleRange       = 0.0003;

  this(SelectScene owner) {
    owner_ = owner;
  }

  abstract UpdateResult Update(KeyInput input);

  @property SelectScene owner() {
    return owner_;
  }

 protected:
  static UpdateResult CreateResult(SceneInterface s) {
    return UpdateResult(s);
  }
  static UpdateResult CreateResult(AbstractSceneState s) {
    return UpdateResult(s);
  }
 private:
  SelectScene owner_;
}

private class FirstSetupState : AbstractSceneState {
 public:
  this(SelectScene owner) {
    super(owner);
    stage_appear_state_ = new SongAppearState(owner);
  }

  enum AnimeFrames  = 30;
  enum BgInnerColor = vec4(0.4, 0.2, 0.2, 1);
  enum BgOuterColor = vec4(-0.4, -0.4, -0.4, 1);

  void Initialize() {
    anime_ = Animation(AnimeFrames);
    with (owner.lobby_) {
      bg_inner_ease_ = Easing!vec4(background.inner_color, BgInnerColor);
      bg_outer_ease_ = Easing!vec4(background.outer_color, BgOuterColor);

      cube_interval_ease_ = Easing!float(cube_interval, LoadingCubeInterval);
    }
    owner.text_.Clear();
  }
  override UpdateResult Update(KeyInput input) {
    const ratio = anime_.Update();

    owner.lobby_.cube_matrix.rotation += LoadingCubeRotationSpeed * (ratio+0.2);
    owner.lobby_.cube_interval = cube_interval_ease_.Calculate(ratio);

    owner.lobby_.background.inner_color = bg_inner_ease_.Calculate(ratio);
    owner.lobby_.background.outer_color = bg_outer_ease_.Calculate(ratio);

    if (anime_.isFinished) {
      stage_appear_state_.Initialize(0);
      return CreateResult(stage_appear_state_);
    }
    return CreateResult(this);
  }

 private:
  SongAppearState stage_appear_state_;

  Animation anime_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;

  Easing!float cube_interval_ease_;
}
private class SongAppearState : AbstractSceneState {
 public:
  this(SelectScene owner) {
    super(owner);
    song_wait_state_ = new SongWaitState(owner, this);
  }

  enum AnimeFrames = 30;

  void Initialize(size_t song_index) {
    song_index_ = song_index;

    anime_ = Animation(AnimeFrames);

    with (owner.lobby_) {
      cube_rota_speed_ease_ = Easing!vec3(
          LoadingCubeRotationSpeed, CubeRotationSpeed);
      cube_interval_ease_ = Easing!float(LoadingCubeInterval, 0.005);

      with (owner.songs_[song_index_].preview) {
        bg_inner_ease_ = Easing!vec4(background.inner_color, bg_inner_color);
        bg_outer_ease_ = Easing!vec4(background.outer_color, bg_outer_color);
      }
    }

    sfSound_setBuffer(owner.sound_, owner.soundres_.spotlight);
    sfSound_play(owner.sound_);

    const song = owner.songs_[song_index_];
    with (owner.text_) {
      const w = LoadGlyphs(vec2i(1024, 64),
          song.name.to!dstring, vec2i(TitleTextSize, 0), owner.fonts_.gothic);
      matrix.scale       = TitleTextScale;
      matrix.translation = TitleTextTranslation + vec3(-w/2*matrix.scale.x, 0, 0);
    }
  }
  override UpdateResult Update(KeyInput input) {
    const ratio = anime_.Update();

    with (owner.lobby_) {
      cube_matrix.rotation += cube_rota_speed_ease_.Calculate(ratio);
      cube_interval         = cube_interval_ease_.Calculate(ratio);

      background.inner_color = bg_inner_ease_.Calculate(ratio);
      background.outer_color = bg_outer_ease_.Calculate(ratio);
    }

    if (anime_.isFinished) {
      song_wait_state_.Initialize(song_index_);
      return CreateResult(song_wait_state_);
    }
    return CreateResult(this);
  }

 private:
  SongWaitState song_wait_state_;

  size_t song_index_;

  Animation anime_;

  Easing!vec3  cube_rota_speed_ease_;
  Easing!float cube_interval_ease_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
}
private class SongWaitState : AbstractSceneState {
 public:
  this(SelectScene owner, SongAppearState song_appear_state) {
    super(owner);
    song_appear_state_ = song_appear_state;
  }

  void Initialize(size_t song_index) {
    song_index_ = song_index;

    auto song = owner.songs_[song_index_];
    song.PlayForPreview();

    with (owner.text_) {
      matrix.scale       = TitleTextScale;
      matrix.translation =
        TitleTextTranslation + vec3(-modelWidth/2*matrix.scale.x, 0, 0);
    }
  }
  override UpdateResult Update(KeyInput input) {
    owner.lobby_.cube_matrix.rotation += CubeRotationSpeed;

    if (input.up) {
      song.StopPlaying();
      owner.title_scene_.Initialize();
      return CreateResult(owner.title_scene_);
    }
    if (input.left && song_index_ != 0) {
      song.StopPlaying();
      song_appear_state_.Initialize(song_index_-1);
      return CreateResult(song_appear_state_);
    }
    if (input.right && song_index_+1 < owner.songs_.length) {
      song.StopPlaying();
      song_appear_state_.Initialize(song_index_+1);
      return CreateResult(song_appear_state_);
    }

    return CreateResult(this);
  }

 private:
  @property Song song() {
    return owner.songs_[song_index_];
  }

  SongAppearState song_appear_state_;

  size_t song_index_;
}
