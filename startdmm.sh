#!/bin/bash

if [ ! $UID == 0 ]; then
  echo "use sudo"
  exit 1
fi

# TODO suspend thing does not work but the script works anyway
./he2325u/suspend.HE2325U.sh

./he2325u/he2325u | ./dmmut61bcd/dmmut61bcd.pl "$@"
