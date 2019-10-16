/// License: MIT
module sj.PlayScene;

import std.conv;

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
  enum BaseScore = 100000;
  ///
  enum DamageScoreRatio = 10;
  ///
  enum NearnessScoreRatio = 10;

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
  void Initialize(Music music, sjplayer.Context context, float offset_beat) {
    music_   = music;
    context_ = context;

    score_ = BaseScore;

    music_.PlayForGame(offset_beat);
  }
  override SceneInterface Update(KeyInput input) {
    beat_ = music_.beat;

    if (beat_ >= context_.length) {
      music_.StopPlaying();

      result_scene_.Initialize(music_, score_);
      return result_scene_;
    }

    context_.OperateScheduledControllers(beat_);

    context_.actor.Accelarate(GetAccelarationFromKeyInput(input));

    context_.actor.Update();
    context_.posteffect.Update();

    const dmg      = context_.CalculateDamage();
    const damage   = (DamageScoreRatio   * dmg.damage).to!int;
    const nearness = (NearnessScoreRatio * dmg.nearness).to!int;

    if (damage != 0) {
      score_ -= damage;
      context_.posteffect.CauseDamagedEffect();
    }
    if (nearness != 0) {
      score_ += nearness;
    }
    return this;
  }
  override void Draw() {
    context_.StartDrawing();

    context_.DrawBackground();
    context_.DrawElements();
    context_.DrawActor();

    context_.EndDrawing();

    if (beat_ >= context_.length) {
      context_.destroy();
    }
  }

 private:
  static vec2 GetAccelarationFromKeyInput(KeyInput key) {
    auto result = vec2(0, 0);
    if (key.left)  result.x -= 1;
    if (key.right) result.x += 1;
    if (key.up)    result.y += 1;
    if (key.down)  result.y -= 1;
    return result;
  }

  ResultScene result_scene_;

  Music            music_;
  sjplayer.Context context_;

  float beat_;
  int   score_;
}
