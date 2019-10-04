// this is comment

$define horming {
  translate_x += cos(atan(player_y, player_x)) * $horming_speed;
  translate_y += sin(atan(player_y, player_x)) * $horming_speed;
}

A [0..10] {
  translate_x = 0.5 + sin(rtime)*0.5;
  translate_y = 0.5 + cos(rtime)*0.5;
}

B [5..15] {
  $define horming_speed {0.1}
  $horming
}
