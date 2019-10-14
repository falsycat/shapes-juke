/// License: MIT
module sj.PlayScene;

import gl4d;

static import sjplayer;

import sj.KeyInput,
       sj.Music,
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
  void SetupSceneDependency() {  // TODO: add result scene
  }

  ///
  void Initialize(Music music, sjplayer.Context context) {
    music_   = music;
    context_ = context;

    music_.PlayForGame();
  }
  override SceneInterface Update(KeyInput input) {
    context_.OperateScheduledControllers(music_.beat);

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
  Music            music_;
  sjplayer.Context context_;
}
