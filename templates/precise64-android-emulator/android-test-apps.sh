#!/usr/bin/env bash

CURRENT=$(cd $(dirname $0) && pwd)
source ~vagrant/android-common.sh

android list avd | grep test > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating avd for test..."
  echo no | android create avd --force -n ${AVDNAME} -t android-17 > /dev/null 2>&1
fi

echo "Starting emulator..."
emulator -avd ${AVDNAME} -no-skin -no-audio -no-window > /dev/null 2>&1 &

~vagrant/android-wait-for-emulator.sh

echo "Testing android apps..."
for i in $(ls ${APPS_DIR}); do
  echo "  Testing app: ${i}"
  pushd ${APPS_DIR}/${i} > /dev/null 2>&1
  ./gradlew connectedAndroidTest
  popd > /dev/null 2>&1
done

echo "Stopping emulator..."
adb emu kill > /dev/null 2>&1
