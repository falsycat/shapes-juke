// this is comment

$define pi {3.14}

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

$define beat {sin($pi/4)}
A [$beat..$beat+10] {
  $define sinwave_add_x {0.5}
  $define sinwave_add_y {0.5}
  $define sinwave_amp_x {0.5}
  $define sinwave_amp_y {0.5}
  $define sinwave_hz    {2}
  $sinwave
}

$define beat {10}
B [$beat..$beat+10/2] {
  $define horming_speed {0.1}
  $horming
}

$define beat {20}
C [$beat..$beat+10/2] {
  $define shoot_speed {0.1}
  $shoot
}
