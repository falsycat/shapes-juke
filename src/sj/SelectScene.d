/// License: MIT
module sj.SelectScene;

import std.math,
       std.variant;

import derelict.sfml2.audio;

import gl4d;

import sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.Song,
       sj.TitleScene,
       sj.util.Animation,
       sj.util.Easing,
       sj.util.audio;

///
class SelectScene : SceneInterface {
 public:

  ///
  this(LobbyWorld lobby, ProgramSet program, Song[] songs) {
    lobby_ = lobby;
    songs_ = songs.dup;

    sound_ = sfSound_create();
    soundres_.Load();

    first_state_ = new FirstSetupState(this);
    status_      = first_state_;
  }
  ~this() {
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

  Song[] songs_;

  sfSound*       sound_;
  SoundResources soundres_;

  FirstSetupState    first_state_;
  AbstractSceneState status_;
}

private abstract class AbstractSceneState {
 public:
  alias UpdateResult = Algebraic!(AbstractSceneState, SceneInterface);

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

  enum CubeRotationSpeed = vec3(0, PI/5, 0);
  enum CubeInterval   = 0.06;

  void Initialize() {
    anime_ = Animation(AnimeFrames);
    bg_inner_ease_ = Easing!vec4(owner.lobby_.background.inner_color, BgInnerColor);
    bg_outer_ease_ = Easing!vec4(owner.lobby_.background.outer_color, BgOuterColor);

    cube_interval_ease_ = Easing!float(owner.lobby_.cube_interval, CubeInterval);
  }
  override UpdateResult Update(KeyInput input) {
    const ratio = anime_.Update();

    owner.lobby_.cube_matrix.rotation += CubeRotationSpeed * (ratio+0.2);
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
  }

  enum AnimeFrames       = 30;
  enum CubeRotationSpeed = vec3(0, PI/500, 0);

  void Initialize(size_t song_index) {
    song_index_ = song_index;

    anime_ = Animation(AnimeFrames);

    auto lobby = owner.lobby_;

    cube_rota_speed_ease_ = Easing!vec3(
        FirstSetupState.CubeRotationSpeed, CubeRotationSpeed);
    cube_interval_ease_ = Easing!float(lobby.cube_interval, 0.005);

    with (owner.songs_[song_index_].preview) {
      bg_inner_ease_ = Easing!vec4(lobby.background.inner_color, bg_inner_color);
      bg_outer_ease_ = Easing!vec4(lobby.background.outer_color, bg_outer_color);
    }

    sfSound_setBuffer(owner.sound_, owner.soundres_.spotlight);
    sfSound_play(owner.sound_);
  }
  override UpdateResult Update(KeyInput input) {
    const ratio = anime_.Update();

    owner.lobby_.cube_matrix.rotation += cube_rota_speed_ease_.Calculate(ratio);
    owner.lobby_.cube_interval         = cube_interval_ease_.Calculate(ratio);

    owner.lobby_.background.inner_color = bg_inner_ease_.Calculate(ratio);
    owner.lobby_.background.outer_color = bg_outer_ease_.Calculate(ratio);
    return CreateResult(this);
  }

 private:
  size_t song_index_;

  Animation anime_;

  Easing!vec3  cube_rota_speed_ease_;
  Easing!float cube_interval_ease_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
}
