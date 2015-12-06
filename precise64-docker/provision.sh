#!/usr/bin/env bash

which curl > /dev/null 2>&1
if [ $? -ne 0 ]; then
  apt-get install -y curl
fi

which docker > /dev/null 2>&1
if [ $? -ne 0 ]; then
  apt-get install -y linux-image-generic-lts-raring linux-headers-generic-lts-raring
  curl -s https://get.docker.io/ubuntu/ | sudo sh
fi

apt-get clean -y
apt-get autoclean -y
find /var/log -type f | while read f; do echo -ne '' > $f; done;

rm -f /home/vagrant/.bash_history
rm -f /home/vagrant/.bash_logout
