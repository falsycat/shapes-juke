/// License: MIT
module sj.SelectScene;

import derelict.sfml2.audio;

import sj.AbstractScene,
       sj.KeyInput,
       sj.LobbyWorld,
       sj.ProgramSet,
       sj.SceneInterface;

///
class SelectScene : AbstractScene {
 public:
  ///
  enum SpotlightSound = cast(ubyte[]) import("sounds/spotlight.wav");

  ///
  this(LobbyWorld lobby, ProgramSet program) {
    lobby_ = lobby;

    const buf = SpotlightSound;
    spotlight_buffer_ = sfSoundBuffer_createFromMemory(buf.ptr, buf.length);
    sound_            = sfSound_create();

    first_ = true;
  }
  ~this() {
    sfSound_destroy(sound_);
    sfSoundBuffer_destroy(spotlight_buffer_);
  }

  ///
  void SetupSceneDependency(SceneInterface title_scene) {
    title_scene_ = title_scene;
  }

  override void Update(KeyInput input) {
    if (first_) {
      sfSound_setBuffer(sound_, spotlight_buffer_);
      sfSound_play(sound_);
    }
    first_ = false;

    if (input.up) GoNextScene(title_scene_);
  }
  override void Draw() {
    lobby_.Draw();
  }

 private:
  SceneInterface title_scene_;

  LobbyWorld lobby_;

  sfSoundBuffer* spotlight_buffer_;

  sfSound* sound_;

  bool first_;
}
