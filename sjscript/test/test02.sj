$define beat {0}

$repeat i 100 {
  A [$i*5+$beat..($i+1)*5+$beat] {
    damage = 1;
  }
}
