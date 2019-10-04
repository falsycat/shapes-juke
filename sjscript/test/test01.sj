// this is comment

$define sinwave {
  translate_x = $sinwave_add_x + sin(rtime * $sinwave_hz) * $sinwave_amp_x;
  translate_y = $sinwave_add_y + cos(rtime * $sinwave_hz) * $sinwave_amp_y;
}
$define horming {
  translate_x += cos(atan(player_y, player_x)) * $horming_speed;
  translate_y += sin(atan(player_y, player_x)) * $horming_speed;
}
$define shoot {
  __dir_x := cos(atan(player_y, player_x)) * $shoot_speed;
  __dir_y := sin(atan(player_y, player_x)) * $shoot_speed;

  translate_x += __dir_x;
  translate_y += __dir_y;
}

A [0..10] {
  $define sinwave_add_x {0.5}
  $define sinwave_add_y {0.5}
  $define sinwave_amp_x {0.5}
  $define sinwave_amp_y {0.5}
  $define sinwave_hz    {2}
  $sinwave
}
B [10..20] {
  $define horming_speed {0.1}
  $horming
}
C [20..30] {
  $define shoot_speed {0.1}
  $shoot
}
