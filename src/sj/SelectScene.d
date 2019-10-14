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
       sj.LoadingScene,
       sj.LobbyWorld,
       sj.Music,
       sj.ProgramSet,
       sj.SceneInterface,
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
  enum DescTextScale = vec3(-0.1, 0.1, 0.1);
  ///
  enum DescTextTranslation = vec3(0, -0.3, 0);
  ///
  enum DescTextColor = vec4(0.2, 0.2, 0.2, 1);

  ///
  this(LobbyWorld lobby, ProgramSet program, FontSet fonts, Music[] music_list) {
    lobby_      = lobby;
    music_list_ = music_list.dup;

    fonts_ = fonts;
    description_text_ = new Text(program.Get!TextProgram);
    title_text_       = new Text(program.Get!TextProgram);

    sound_ = sfSound_create();
    soundres_.Load();

    first_state_ = new FirstSetupState(this);
    status_      = first_state_;

    with (description_text_) {
      const w = LoadGlyphs(
          vec2i(256, 32), "MUSIC SELECT", vec2i(16, 0), fonts_.gothic);
      matrix.scale       = DescTextScale;
      matrix.translation =
        DescTextTranslation + vec3(-w/2*matrix.scale.x, 0, 0);
      color = DescTextColor;
    }
  }
  ~this() {
    description_text_.destroy();
    title_text_.destroy();

    sfSound_destroy(sound_);
    soundres_.Unload();
  }

  ///
  void SetupSceneDependency(TitleScene title_scene, LoadingScene load_scene) {
    title_scene_ = title_scene;
    load_scene_  = load_scene;
  }

  ///
  void Initialize() {
    first_state_.Initialize();
    status_ = first_state_;
  }
  override SceneInterface Update(KeyInput input) {
    SceneInterface     next_scene = this;
    AbstractSceneState next_state = status_;

    status_.Update(input).visit!(
        (SceneInterface     scene) { next_scene = scene; },
        (AbstractSceneState state) { next_state = state; }
      );
    status_ = next_state;
    return next_scene;
  }
  override void Draw() {
    lobby_.Draw();
    status_.Draw();
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

  TitleScene   title_scene_;
  LoadingScene load_scene_;

  LobbyWorld lobby_;

  Text    description_text_;
  Text    title_text_;
  FontSet fonts_;

  Music[] music_list_;

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
  enum TitleTextScale       = vec3(-0.1, 0.1, 0.1);
  enum TitleTextTranslation = vec3(0, -0.4, 0);

  enum TitleTextRandomTranslationRange = 0.02;
  enum TitleTextRandomScaleRange       = 0.0003;

  this(SelectScene owner) {
    owner_ = owner;
  }

  abstract UpdateResult Update(KeyInput input);

  void Draw() {
  }

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
    music_appear_state_ = new MusicAppearState(owner);
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
    owner.title_text_.Clear();
  }
  override UpdateResult Update(KeyInput input) {
    const ratio = anime_.Update();

    with (owner.lobby_) {
      cube_matrix.rotation += LoadingCubeRotationSpeed * (ratio+0.2);
      cube_interval = cube_interval_ease_.Calculate(ratio);

      background.inner_color = bg_inner_ease_.Calculate(ratio);
      background.outer_color = bg_outer_ease_.Calculate(ratio);
    }

    if (anime_.isFinished) {
      music_appear_state_.Initialize(0);
      return CreateResult(music_appear_state_);
    }
    return CreateResult(this);
  }

 private:
  MusicAppearState music_appear_state_;

  Animation anime_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;

  Easing!float cube_interval_ease_;
}
private class MusicAppearState : AbstractSceneState {
 public:
  this(SelectScene owner) {
    super(owner);
    music_wait_state_ = new MusicWaitState(owner, this);
  }

  enum AnimeFrames = 30;

  void Initialize(size_t music_index) {
    music_index_ = music_index;

    anime_ = Animation(AnimeFrames);

    with (owner.lobby_) {
      cube_rota_speed_ease_ = Easing!vec3(
          LoadingCubeRotationSpeed, CubeRotationSpeed);
      cube_interval_ease_ = Easing!float(LoadingCubeInterval, 0.005);

      with (owner.music_list_[music_index_].preview) {
        bg_inner_ease_ = Easing!vec4(background.inner_color, bg_inner_color);
        bg_outer_ease_ = Easing!vec4(background.outer_color, bg_outer_color);
      }
    }

    sfSound_setBuffer(owner.sound_, owner.soundres_.spotlight);
    sfSound_play(owner.sound_);

    const music = owner.music_list_[music_index_];
    with (owner.title_text_) {
      const w = LoadGlyphs(vec2i(1024, 64),
          music.name.to!dstring, vec2i(TitleTextSize, 0), owner.fonts_.gothic);
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
      music_wait_state_.Initialize(music_index_);
      return CreateResult(music_wait_state_);
    }
    return CreateResult(this);
  }
  override void Draw() {
    const view = owner.lobby_.view.Create();
    owner.description_text_.Draw(owner.lobby_.Projection, view);
    owner.title_text_      .Draw(owner.lobby_.Projection, view);
  }

 private:
  MusicWaitState music_wait_state_;

  size_t music_index_;

  Animation anime_;

  Easing!vec3  cube_rota_speed_ease_;
  Easing!float cube_interval_ease_;

  Easing!vec4 bg_inner_ease_;
  Easing!vec4 bg_outer_ease_;
}
private class MusicWaitState : AbstractSceneState {
 public:
  this(SelectScene owner, MusicAppearState music_appear_state) {
    super(owner);
    music_appear_state_ = music_appear_state;
  }

  void Initialize(size_t music_index) {
    music_index_ = music_index;
    music.PlayForPreview();
  }
  override UpdateResult Update(KeyInput input) {
    owner.lobby_.cube_matrix.rotation += CubeRotationSpeed;

    if (input.up) {
      music.StopPlaying();
      owner.title_scene_.Initialize();
      return CreateResult(owner.title_scene_);
    }
    if (input.down) {
      music.StopPlaying();
      owner.load_scene_.Initialize(music);
      return CreateResult(owner.load_scene_);
    }

    if (input.left && music_index_ != 0) {
      music.StopPlaying();
      music_appear_state_.Initialize(music_index_-1);
      return CreateResult(music_appear_state_);
    }
    if (input.right && music_index_+1 < owner.music_list_.length) {
      music.StopPlaying();
      music_appear_state_.Initialize(music_index_+1);
      return CreateResult(music_appear_state_);
    }

    return CreateResult(this);
  }
  override void Draw() {
    const view = owner.lobby_.view.Create();
    owner.description_text_.Draw(owner.lobby_.Projection, view);
    owner.title_text_      .Draw(owner.lobby_.Projection, view);
  }

 private:
  @property Music music() {
    return owner.music_list_[music_index_];
  }

  MusicAppearState music_appear_state_;

  size_t music_index_;
}
