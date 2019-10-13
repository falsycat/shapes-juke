/// License: MIT
module sj.SelectScene;

import derelict.sfml2.audio;

import sj.AbstractScene,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SceneInterface,
       sj.util.audio;

///
class SelectScene : AbstractScene {
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
  void SetupSceneDependency(SceneInterface title_scene) {
    title_scene_ = title_scene;
  }

  override void Update(KeyInput input) {
    if (input.up) GoNextScene(title_scene_);
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

  SceneInterface title_scene_;

  LobbyWorld lobby_;

  sfSound* sound_;

  SoundResources soundres_;
}
