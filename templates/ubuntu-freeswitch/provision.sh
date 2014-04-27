#!/usr/bin/env bash

which curl > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Installing curl..."
  apt-get install -y curl > /dev/null 2>&1
fi

which freeswitch > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Adding FreeSWITCH APT repo..."
  echo 'deb http://files.freeswitch.org/repo/deb/debian/ wheezy main' >> /etc/apt/sources.list.d/freeswitch.list 2> /dev/null
  echo "Importing repo key..."
  curl http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub 2> /dev/null | apt-key add - > /dev/null 2>&1
  echo "Updating apt-get..."
  apt-get update -y -qq > /dev/null 2>&1
  echo "Installing FreeSWITCH..."
  apt-get install -y -qq freeswitch-meta-vanilla > /dev/null 2>&1
  cp -a /usr/share/freeswitch/conf/vanilla /etc/freeswitch
fi

service freeswitch status > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Starting FreeSWITCH..."
  service freeswitch start > /dev/null 2>&1
fi
