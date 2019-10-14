/// License: MIT
module sj.PlayScene;

import gl4d;

static import sjplayer;

import sj.KeyInput,
       sj.Music,
       sj.ResultScene,
       sj.SceneInterface;

///
class PlayScene : SceneInterface {
 public:
  ///
  this() {
  }
  ~this() {
    context_.destroy();
  }

  ///
  void SetupSceneDependency(ResultScene result) {
    result_scene_ = result;
  }

  ///
  void Initialize(Music music, sjplayer.Context context) {
    music_   = music;
    context_ = context;

    music_.PlayForGame();
  }
  override SceneInterface Update(KeyInput input) {
    const beat = music_.beat;

    if (beat >= context_.length) {
      music_.StopPlaying();
      result_scene_.Initialize(music_, 0);  // TODO: pass a proper score
      return result_scene_;
    }

    context_.OperateScheduledControllers(beat);

    // TODO: actor accelaration

    context_.actor.Update();
    context_.posteffect.Update();

    // TODO: damage calculation
    return this;
  }
  override void Draw() {
    context_.StartDrawing();

    context_.DrawBackground();
    context_.DrawElements();
    context_.DrawActor();

    context_.EndDrawing();
  }

 private:
  ResultScene result_scene_;

  Music            music_;
  sjplayer.Context context_;
}
