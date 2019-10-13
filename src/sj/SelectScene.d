/// License: MIT
module sj.SelectScene;

import derelict.sfml2.audio;

import sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.TitleScene,
       sj.util.audio;

///
class SelectScene : SceneInterface {
 public:

  ///
  this(LobbyWorld lobby, ProgramSet program) {
    lobby_ = lobby;

    sound_ = sfSound_create();
    soundres_.Load();
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
  }
  override SceneInterface Update(KeyInput input) {
    if (input.up) {
      title_scene_.Initialize();
      return title_scene_;
    }
    return this;
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

  sfSound* sound_;

  SoundResources soundres_;
}
