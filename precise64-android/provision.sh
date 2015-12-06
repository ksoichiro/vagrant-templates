#!/usr/bin/env bash

pushd ~vagrant > /dev/null 2>&1

if [ ! -d ~vagrant/android-sdk-linux ]; then
  echo "Installing android sdk..."
  wget http://dl.google.com/android/android-sdk_r22.6-linux.tgz > /dev/null 2>&1
  tar xzf android-sdk_r22.6-linux.tgz > /dev/null 2>&1
  rm -f android-sdk_r22.6-linux.tgz > /dev/null 2>&1
fi

grep android ~vagrant/.bashrc > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'export ANDROID_HOME=~vagrant/android-sdk-linux' >> ~vagrant/.bashrc
  echo 'export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools' >> ~vagrant/.bashrc
fi

export ANDROID_HOME=~vagrant/android-sdk-linux
export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

which java > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Installing jdk..."
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -y -qq --force-yes openjdk-7-jdk > /dev/null 2>&1
fi

which adb > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Installing dependencies for android..."
  sudo apt-get install -y -qq --force-yes libgd2-xpm ia32-libs ia32-libs-multiarch > /dev/null 2>&1

  echo "Installing android sdk tools..."
  echo y | android update sdk --filter platform-tools,build-tools-19.0.3,android-17,extra-android-support --no-ui --force > /dev/null 2>&1
fi

popd > /dev/null 2>&1

echo "Copying android scripts..."
cp -p /vagrant/android-*.sh ~vagrant/

source /vagrant/android-common.sh
if [ ! -d ${APPS_DIR} ]; then
  ~vagrant/android-create-apps.sh
fi

sudo apt-get clean -y
sudo apt-get autoclean -y

rm -f /home/vagrant/.bash_history
rm -f /home/vagrant/.bash_logout
