actor [0..100] {
  color_a := 1;

  clip_left := 0.1;
}
background [0..100] {
  inner_r = 0.8;
  inner_g = 0.8;
  inner_b = 0.8;
  inner_a = 1;

  outer_r = 0;
  outer_g = 0;
  outer_b = 0;
  outer_a = 1;
}
posteffect [0..100] {
  clip_left  := 0.1;
  clip_right := 0.1;
}

$repeat i 10 {
  $repeat j 20 {
    circle [$i..$i+2] {
      color_r := 0.8;
      color_g := 0.1;
      color_b := 0.1;
      color_a := 1;

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
