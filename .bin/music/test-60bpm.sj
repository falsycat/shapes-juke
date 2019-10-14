actor [0..1] {
  color_a := 1;

  clip_left := 0.1;
}
background [0..1] {
  inner_r = 0.8;
  inner_g = 0.8;
  inner_b = 0.8;
  inner_a = 1;

  outer_r = 0;
  outer_g = 0;
  outer_b = 0;
  outer_a = 1;
}
posteffect [0..1] {
  clip_left  := 0.1;
  clip_right := 0.1;
}
variable [0..3.5] {
  hoge = 1-time;
}

$repeat i 2 {
  $repeat j 20 {
    circle [$i+1..$i+3] {
      color_r := 0.8;
      color_g := 0.1;
      color_b := 0.1;
      color_a  = hoge;

      damage       := 0.1;
      nearness_coe := 0.01;

      __theta       := 2*3.14/20 * $j;
      translation_x := cos(__theta) * 0.5;
      translation_y := sin(__theta) * 0.5;
      scale_x       := 0.025;
      scale_y       := 0.025;

      __atan    := atan2(actor_y - translation_y, actor_x - translation_x);
      __speed_x := cos(__atan) * 0.015;
      __speed_y := sin(__atan) * 0.015;

      translation_x += __speed_x;
      translation_y += __speed_y;
    }
  }
}
