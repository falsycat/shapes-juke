#!/bin/sh

if [ ! -d ".git" ]; then
  echo "plz run at root of this repository"
  exit 1
fi

function test() {
  result=`$1 "$2"`
  if [ "$result" != "$3" ]; then
    echo "\`$1 \"$2\"\` != \`$3\`"
  fi
}

test ./test/math.d "1+2-3*4/5" "1"
