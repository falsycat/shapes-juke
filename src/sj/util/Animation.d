/// License: MIT
module sj.util.Animation;

import std.algorithm;

///
struct Animation {
 public:
  ///
  this(size_t frame_count) {
    frame_count_ = frame_count;
  }
  ///
  float Update() {
    return (frame_++ * 1f / frame_count_).clamp(0f, 1f);
  }
  ///
  @property bool isFinished() const {
    return frame_ >= frame_count_;
  }
  ///
  @property size_t frame() const {
    return frame_;
  }

 private:
  size_t frame_count_;

  size_t frame_;
}
