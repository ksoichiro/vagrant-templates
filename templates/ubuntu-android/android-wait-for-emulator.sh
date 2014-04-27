#!/usr/bin/env bash

CURRENT=$(cd $(dirname $0) && pwd)
source ~vagrant/android-common.sh

echo "Waiting for emulator to start..."

bootanim=""
failcounter=0
until [[ "$bootanim" =~ "stopped" ]]; do
   bootanim=`adb -e shell getprop init.svc.bootanim 2>&1`
   if [[ "$bootanim" =~ "not found" ]]; then
      let "failcounter += 1"
      if [[ $failcounter -gt 3 ]]; then
        echo "  Failed to start emulator"
        exit 1
      fi
   fi
   sleep 1
done
