$define damage_ratio   {1.0}
$define nearness_ratio {0.01}

// ---- TEMPLATE DECLARATION ----
$define main_color {
  color_r := 1;
  color_g := 0;
  color_b := 0;
  color_a := 0.9;
}

// ---- INITIALIZE ----
actor [0..1] {
  color_a := 1;

  clip_left   := 0;
  clip_right  := 0;
  clip_top    := 9/32;
  clip_bottom := 9/32;
}
background [0..1] {
  inner_r := 0.4;
  inner_g := 0.4;
  inner_b := 0.5;
  inner_a := 1;

  outer_r := 0.1;
  outer_g := 0.1;
  outer_b := 0.1;
  outer_a := 1;
}
posteffect [0..1] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top    := 9/32;
  clip_bottom := 9/32;

  contrast_r := 1.5;
  contrast_g := 1.5;
  contrast_b := 1.5;
}

// ---- INTRO [2..34] ----
$define beat {2}
$repeat i 3 {
  $define main_square {
    $main_color

    scale_x := 0.1;
    scale_y := 0.1;

    rotation_z := PI/4;

    translation_x := $i*0.6 - 0.6;
  }
  square [$beat..$beat+4] {
    $main_square

    damage := $damage_ratio*0.01;
    color_a = step(0.5, sin(PI*(1-pow(time, 2))*10));
  }
  square [$beat+4..$beat+26] {
    $main_square
    damage := $damage_ratio;
  }
  square [$beat+26..$beat+28] {
    $main_square
    weight = pow(1-time, 2);
  }

  $repeat j 8 {
    $repeat k 6 {
      circle [$beat+$j*2+6..$beat+$j*2+16] {
        $main_color

        scale_x := 0.025;
        scale_y := 0.025;

        __theta := $k*PI/3 + $j*PI/10;
        __cos   := cos(__theta);
        __sin   := sin(__theta);

        translation_x = ($i*0.6-0.6) + (time*1.5+0.2)*__cos;
        translation_y = (time*1.5+0.2)*__sin;

        damage := $damage_ratio*0.5;
      }
    }
    square [$beat+$j*2+6..$beat+$j*2+8] {
      $main_square

      scale_x = 0.1+time*0.1;
      scale_y = 0.1+time*0.1;

      color_a = 1-time;

      weight := 0.03;
    }
  }
}

// ---- OUTRO -> A melody [30..34] ----
$define beat {30}
triangle [$beat..$beat+1] {
  $main_color

  scale_x = 0.1 + pow(1-time, 2)*0.05;
  scale_y = 0.1 + pow(1-time, 2)*0.05;

  damage := $damage_ratio * 0.5;
}
square [$beat+1..$beat+2] {
  $main_color

  scale_x := 0.1;
  scale_y := 0.1;

  rotation_z = (1-pow(1-time, 2)) * PI/2;

  weight = 0.03 + time*0.97;

  damage := $damage_ratio * 0.75;
}
square [$beat+2..$beat+3] {
  $main_color

  scale_x  = 0.1 + (1-pow(1-time, 2)) * 0.7;
  scale_y := 0.1;

  damage := $damage_ratio;
}
square [$beat+3..$beat+4] {
  $main_color

  scale_x := 0.8;
  scale_y := 0.1;

  rotation_z = pow(time, 2) * PI;

  damage := $damage_ratio;
}
circle [$beat+4..$beat+5] {
  $main_color

  scale_x = (1-time)*0.8;
  scale_y = (1-time)*0.8;

  damage := $damage_ratio * 0.75;
}

// ---- A melody [34..98] ----
$define beat {34}
$repeat i 16 {
  square [$beat+($i*4)..$beat+($i*4)+2] {
    $main_color

    scale_x := 0.5;
    scale_y := 0.05;

    translation_x = 0.5;
    translation_y = 1 - 2*time;

    damage := $damage_ratio*0.25;
  }
  square [$beat+($i*4)+2..$beat+($i*4)+4] {
    $main_color

    scale_x := 0.5;
    scale_y := 0.05;

    translation_x = -0.5;
    translation_y = 1 - 2*time;

    damage := $damage_ratio*0.25;
  }

  $define lazer_shooter_wrap_circle {
    $main_color
    color_a = 1-time;

    scale_x = (1-pow(1-time, 2)) * 0.3;
    scale_y = (1-pow(1-time, 2)) * 0.3;

    weight := 0.05;
  }
  $define lazer_shooter_triangle {
    $main_color

    scale_x = (1-pow(1-time, 2)) * 0.1;
    scale_y = (1-pow(1-time, 2)) * 0.2;

    rotation_z = PI*2 * (1-pow(1-time, 4)) +
      atan2(actor_y - translation_y, actor_x - translation_x) - PI/2;

    damage = $damage_ratio * 0.5;
  }
  $define lazer {
    $main_color
    color_a = 1-time;

    scale_x    := 0.01;
    scale_y    := 2;
    rotation_z :=
      atan2(actor_y - translation_y, actor_x - translation_x) - PI/2;

    damage = $damage_ratio * pow(time, 2);
  }
  circle [$beat+($i*4)..$beat+($i*4)+1] {
    translation_x := -0.5;
    $lazer_shooter_wrap_circle
  }
  triangle [$beat+($i*4)..$beat+($i*4)+1.5] {
    translation_x := -0.5;
    $lazer_shooter_triangle
  }
  square [$beat+($i*4)+1.5..$beat+($i*4)+2] {
    translation_x := -0.5;
    $lazer
  }

  circle [$beat+($i*4)+2..$beat+($i*4)+3] {
    translation_x := 0.5;
    $lazer_shooter_wrap_circle
  }
  triangle [$beat+($i*4)+2..$beat+($i*4)+3.5] {
    translation_x := 0.5;
    $lazer_shooter_triangle
  }
  square [$beat+($i*4)+3.5..$beat+($i*4)+4] {
    translation_x := 0.5;
    $lazer
  }
}
$define beat {66}
$repeat i 16 {
  $repeat x 3 {
    circle [$beat+($i*2)..$beat+($i*2)+8] {
      $main_color

      scale_x := 0.025;
      scale_y := 0.025;

      translation_x = ($x-1)*0.4 + sin(time*PI*6) * 0.1;
      translation_y = 1 - time * 2;

      damage := $damage_ratio;
    }
  }
}

// ---- A melody -> B melody [98..102] ----
$define beat {98}
$repeat x 3 {
  $repeat i 3 {
    triangle [$beat+$i/3..$beat+($i+4)/3] {
      $main_color
      color_a = 0.8 - time*0.8;

      scale_x := 0.15;
      scale_y := 0.15;

      translation_x := $i*0.06 + ($x-1)*0.6;
      translation_y := -$i*0.05;

      damage := $damage_ratio * 0.5;
    }
  }
}
actor [$beat+2..$beat+4] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 9/32 * (time+1);
  clip_bottom  = 9/32 * (time+1);
}
posteffect [$beat+2..$beat+4] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 9/32 * (time+1);
  clip_bottom  = 9/32 * (time+1);
}

// ---- B melody [102..134] ----
$define beat {102}
$repeat i 12 {
  $repeat y 2 {
    square [$beat+($i*2)+$y..$beat+($i*2)+$y+8] {
      $main_color

      scale_x := 0.03;
      scale_y := 1;

      translation_x  = (time-0.5)*2.1 * ($y-0.5)*2;
      translation_y := ($y-0.5)*2;

      damage       := $damage_ratio;
      nearness_coe := $nearness_ratio;
    }
  }
}
actor [$beat+27..$beat+28] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 9/32 * (2-pow(time, 3));
  clip_bottom  = 9/32 * (2-pow(time, 3));
}
posteffect [$beat+27..$beat+28] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 9/32 * (2-pow(time, 3));
  clip_bottom  = 9/32 * (2-pow(time, 3));
}
$repeat y 2 {
  $repeat x 2 {
    $define translation_x {1.2 * ($x - $y*0.5)}
    $define translation_y {0.6 * ($y-0.5)*2}

    circle [$beat+27..$beat+29] {
      $main_color
      color_a = 1-time;

      scale_x = time * 0.1 + 0.1;
      scale_y = time * 0.1 + 0.1;

      translation_x := $translation_x;
      translation_y := $translation_y;

      weight = 0.3 * (1-time);
    }
    triangle [$beat+27..$beat+28] {
      $main_color

      scale_x = 0.15 * (1-pow(1-time, 4));
      scale_y = 0.15 * (1-pow(1-time, 4));

      translation_x := $translation_x;
      translation_y := $translation_y;

      rotation_z = (pow(1-time, 4) * PI * 2) + $y * PI;

      damage := $damage_ratio * 0.2;
    }
    triangle [$beat+28..$beat+29] {
      $main_color

      scale_x  = 0.15 - 0.05 * (1-pow(1-time, 4));
      scale_y := 0.15;

      translation_x := $translation_x;
      translation_y := $translation_y;

      rotation_z := $y * PI;

      damage := $damage_ratio;
    }
    square [$beat+29..$beat+32] {
      $main_color
      color_a = 1-time;

      scale_x := 0.01;
      scale_y := 1;

      translation_x := $translation_x;

      damage       = (1-time) * $damage_ratio;
      nearness_coe = $nearness_ratio;
    }
  }
}

// ---- C melody [134..166] ----
$define beat {134}
$repeat i 4 {
  square [$beat+$i*8..$beat+$i*8+4] {
    $main_color
    scale_x = 0.1 * pow(1-time, 2);
    scale_y = 0.1 * pow(1-time, 2);

    rotation_z = time * PI * 2;

    damage := $damage_ratio;
  }
  circle [$beat+$i*8+1..$beat+$i*8+2] {
    $main_color
    color_a = time;

    scale_x = 0.1 + pow(time, 4) * 0.2;
    scale_y = 0.1 + pow(time, 4) * 0.2;

    weight = pow(1-time, 2) * 0.8 + 0.2;

    damage       := $damage_ratio;
    nearness_coe := $nearness_ratio;
  }
  $repeat t 10 {
    square [$beat+$i*8+2..$beat+$i*8+4] {
      $main_color

      scale_y = 0.02;
      scale_x = pow(1-time, 2) * 0.3;

      __theta    := PI*2 * $t/10;
      rotation_z := __theta;

      __sin = sin(__theta);
      __cos = cos(__theta);
      translation_x = __cos * (time+0.35);
      translation_y = __sin * (time+0.35);

      damage       := $damage_ratio;
      nearness_coe := $nearness_ratio;
    }
  }
  square [$beat+$i*8+2..$beat+$i*8+3] {
    $main_color

    scale_x := 0.5;
    scale_y := 0.1;

    translation_x = 0.5;
    translation_y = 1 - 2*pow(time, 2);

    damage := $damage_ratio*0.25;
  }
  square [$beat+$i*8+3..$beat+$i*8+4] {
    $main_color

    scale_x := 0.5;
    scale_y := 0.1;

    translation_x = -0.5;
    translation_y = 1 - 2*pow(time, 2);

    damage := $damage_ratio*0.25;
  }
  $repeat y 10 {
    circle [$beat+$i*8+4..$beat+$i*8+8] {
      $main_color

      scale_x := 0.025;
      scale_y := 0.025;

      translation_x = 1-time*2;
      translation_y = ($y-5)*0.2 + sin(time*PI*3) * 0.2;

      damage       := $damage_ratio;
      nearness_coe := $nearness_ratio;
    }
  }
}

// ---- C melody -> D melody [158..162] ----
$define beat {158}
$repeat y 2 {
  $define translation_x {0.6 * ($y-0.5)*2}
  $define translation_y {0.6 * ($y-0.5)*2}

  circle [$beat+2..$beat+4] {
    $main_color
    color_a = 1-time;

    scale_x = time * 0.1 + 0.1;
    scale_y = time * 0.1 + 0.1;

    translation_x := $translation_x;
    translation_y := $translation_y;

    weight = 0.3 * (1-time);
  }
  triangle [$beat+2..$beat+3] {
    $main_color

    scale_x = 0.15 * (1-pow(1-time, 4));
    scale_y = 0.15 * (1-pow(1-time, 4));

    translation_x := $translation_x;
    translation_y := $translation_y;

    rotation_z = (pow(1-time, 4) * PI * 2) + $y * PI;

    damage := $damage_ratio * 0.2;
  }
  triangle [$beat+2..$beat+4] {
    $main_color

    scale_x  = 0.15 - 0.05 * (1-pow(1-time, 4));
    scale_y := 0.15;

    translation_x := $translation_x;
    translation_y := $translation_y;

    rotation_z := $y * PI;

    damage := $damage_ratio;
  }
  square [$beat+4..$beat+7] {
    $main_color
    color_a = 1-time;

    scale_x := 0.01;
    scale_y := 1;

    translation_x := $translation_x;

    damage       = (1-time) * $damage_ratio;
    nearness_coe = $nearness_ratio;
  }
}

// ---- D melody [162..194] ----
$define beat {162}
$repeat i 8 {
  $define falling_triangle {
    $main_color

    scale_x := 0.35;
    scale_y := 0.20;

    rotation_z := PI;

    damage := $damage_ratio;
  }
  triangle [$beat+$i*4..$beat+$i*4+1] {
    $falling_triangle
    translation_y = pow(1-time, 2);
  }
  triangle [$beat+$i*4+1..$beat+$i*4+2] {
    $falling_triangle
    translation_y = -pow(time, 2);
  }

  $repeat x 2 {
    $define translation_x {($x*2-1)}
    triangle [$beat+$i*4+2..$beat+$i*4+3] {
      $falling_triangle
      translation_y  = pow(1-time, 2);
      translation_x := $translation_x * 0.7;
    }
    triangle [$beat+$i*4+3..$beat+$i*4+4] {
      $falling_triangle
      translation_y  = -pow(time, 2);
      translation_x := $translation_x * 0.7;
    }
  }

  $repeat x 2 {
    $repeat y 3 {
      circle [$beat+$i*4..$beat+$i*4+12] {
        $main_color

        scale_x = 0.025;
        scale_y = 0.025;

        translation_x := 1.1 * ($x*2-1);
        translation_y := $y-1;

        __theta := atan2(actor_y - translation_y, actor_x - translation_x);
        __cos   := cos(__theta);
        __sin   := sin(__theta);

        translation_x += __cos * 0.01;
        translation_y += __sin * 0.01;

        damage := $damage_ratio;
      }
    }
  }
}

// ---- D melody -> E melody [194..198]
$define beat {194}
posteffect [$beat..$beat+1] {
  contrast_r = 1 + pow(1-time, 2)*0.5;
  contrast_g = 1 + pow(1-time, 2)*0.5;
  contrast_b = 1 + pow(1-time, 2)*0.5;
}
posteffect [$beat+1..$beat+2] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 9/32 * pow(1-time, 2);
  clip_bottom  = 9/32 * pow(1-time, 2);
}
actor [$beat+1..$beat+2] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 9/32 * pow(1-time, 2);
  clip_bottom  = 9/32 * pow(1-time, 2);
}

// ---- E melody [198..262] ----
$define beat {198}
$repeat i 16 {
  $define falling_bar {
    $main_color

    scale_y := 0.1;

    damage := $damage_ratio*0.25;
  }
  square [$beat+($i*4)+2..$beat+($i*4)+3] {
    $falling_bar
    scale_x       := 0.4;

    translation_x := -0.75;
    translation_y  = -(1 - 2*time);
  }
  square [$beat+($i*4)+2..$beat+($i*4)+3] {
    $falling_bar
    scale_x       := 0.4;

    translation_x := 0.75;
    translation_y  = -(1 - 2*time);
  }

  $repeat x 3 {
    $define lazer {
      $main_color
      color_a = 1-time;

      scale_x := 0.01;

      damage = $damage_ratio*time;
    }
    square [$beat+($i*4)+$x*0.3+2..$beat+($i*4)+4] {
      $lazer
      translation_x := 0.5 + $x*0.2;
    }
    square [$beat+($i*4)+$x*0.3+2..$beat+($i*4)+4] {
      $lazer
      translation_x := -(0.5 + $x*0.2);
    }
  }

  $define lazer_shooter_wrap_circle {
    $main_color
    color_a = 1-time;

    scale_x = (1-pow(1-time, 2)) * 0.3;
    scale_y = (1-pow(1-time, 2)) * 0.3;

    weight := 0.05;
  }
  $define lazer_shooter_triangle {
    $main_color

    scale_x = (1-pow(1-time, 2)) * 0.1;
    scale_y = (1-pow(1-time, 2)) * 0.2;

    rotation_z = PI*2 * (1-pow(1-time, 4)) +
      atan2(actor_y - translation_y, actor_x - translation_x) - PI/2;

    damage = $damage_ratio * 0.5;
  }
  $define lazer {
    $main_color
    color_a = 1-time;

    scale_x    := 0.01;
    scale_y    := 2;
    rotation_z :=
      atan2(actor_y - translation_y, actor_x - translation_x) - PI/2;

    damage = $damage_ratio * pow(time, 2);
  }
  $repeat x 2 {
    $repeat y 2 {
      $define translation_x {($x-0.5)*1.2}
      $define translation_y {($y-0.5)/2}
      circle [$beat+($i*4)..$beat+($i*4)+1] {
        translation_x := $translation_x;
        translation_y := $translation_y;
        $lazer_shooter_wrap_circle
      }
      triangle [$beat+($i*4)..$beat+($i*4)+1.5] {
        translation_x := $translation_x;
        translation_y := $translation_y;
        $lazer_shooter_triangle
      }
      square [$beat+($i*4)+1.5..$beat+($i*4)+2] {
        translation_x := $translation_x;
        translation_y := $translation_y;
        $lazer
      }
    }
  }
  $repeat y 10 {
    circle [$beat+$i*4..$beat+$i*4+4] {
      $main_color

      scale_x := 0.025;
      scale_y := 0.025;

      translation_x = ($y-5)*0.2 + sin(time*PI*3) * 0.2;
      translation_y = -(1-time*2);

      damage       := $damage_ratio;
      nearness_coe := $nearness_ratio;
    }
  }
}

// ---- Outro [262..276] ----
$define beat {262}
$repeat i 2 {
  square [$beat..$beat+1] {
    $main_color
    scale_x := 0.2;
    scale_y := 0.02;

    rotation_z = (PI/6 * pow(1-time, 4) + PI/6) * ($i-0.5)*2;

    damage := $damage_ratio;
  }
  square [$beat+1..$beat+2] {
    $main_color
    scale_x := 0.2;
    scale_y := 0.02;
    rotation_z = PI/6 * pow(1-time, 4) * ($i-0.5)*2;

    damage := $damage_ratio;
  }
}
square [$beat+2..$beat+3] {
  $main_color
  scale_x  = 0.2 * (1-time);
  scale_y := 0.02;

  damage := $damage_ratio;
}
$repeat y 5 {
  $repeat x 5 {
    square [$beat+3+$y*0.2..$beat+3+$y*0.2+2] {
      $main_color
      color_a = pow(1-abs(time*2-1), 2) * 0.5;

      scale_x := 0.15;
      scale_y := 0.15;

      translation_x := ($x-2.5) / 2.5 + 0.2;
      translation_y := ($y-2.5) / 2.5 + 0.2;

      damage = color_a * $damage_ratio * 0.25;
    }
  }
}

// ---- Ending ----
posteffect [276..280] {
  clip_left   := 0;
  clip_right  := 0;
  clip_top     = 1-pow(1-time, 4);
  clip_bottom  = 1-pow(1-time, 4);

  contrast_r = 1+9*time;
  contrast_g = 1+9*time;
  contrast_b = 1+9*time;
}


// ---- IDEA BOX ----
// [cross]
//$repeat x 2 {
//  $repeat y 10 {
//    $repeat i 16 {
//      square [$beat+($i*2)..$beat+($i*2)+2] {
//        $main_color
//
//        translation_y := -1 + $y/5;
//        translation_x := -0.7 + $x*1.4;
//
//        scale_x := 0.06;
//        scale_y := 0.01;
//        rotation_z = pow(time, 3) * PI / 2;
//
//        damage = $damage_ratio;
//      }
//      square [$beat+($i*2)..$beat+($i*2)+2] {
//        $main_color
//
//        translation_y := -1 + $y/5;
//        translation_x := -0.7 + $x*1.4;
//
//        scale_x := 0.01;
//        scale_y := 0.06;
//        rotation_z = pow(time, 3) * PI / 2;
//
//        damage = $damage_ratio;
//      }
//    }
//  }
//}
