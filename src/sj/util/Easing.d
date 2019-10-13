/// License: MIT
module sj.util.Easing;

///
enum EasingType {
  Linear,
  LinearMountain,
}

///
struct Easing(T) {
 public:
  ///
  this(T st, T ed, EasingType type = EasingType.Linear) {
    st_   = st;
    ed_   = ed;
    type_ = type;
  }

  ///
  T Calculate(float t) {
    final switch (type_) with (EasingType) {
      case LinearMountain:
        t = t*2;
        t = t > 1? 2-t: t;
        goto case;
      case Linear:
        return (ed_ - st_) * t + st_;
    }
  }

 private:
  T st_;
  T ed_;

  EasingType type_;
}
