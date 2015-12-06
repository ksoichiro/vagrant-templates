#!/usr/bin/env bash

# 日本のミラーサイトを利用する
grep "jp.archive.ubuntu.com" /etc/apt/sources.list > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Updating apt-get mirror sites..."
  echo "deb http://jp.archive.ubuntu.com/ubuntu/ precise main restricted
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise main restricted
deb http://jp.archive.ubuntu.com/ubuntu/ precise-updates main restricted
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise-updates main restricted
deb http://jp.archive.ubuntu.com/ubuntu/ precise universe
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise universe
deb http://jp.archive.ubuntu.com/ubuntu/ precise-updates universe
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise-updates universe
deb http://jp.archive.ubuntu.com/ubuntu/ precise multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise multiverse
deb http://jp.archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb http://jp.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu precise-security main restricted
deb-src http://security.ubuntu.com/ubuntu precise-security main restricted
deb http://security.ubuntu.com/ubuntu precise-security universe
deb-src http://security.ubuntu.com/ubuntu precise-security universe
deb http://security.ubuntu.com/ubuntu precise-security multiverse
deb-src http://security.ubuntu.com/ubuntu precise-security multiverse" > /etc/apt/sources.list
fi

# Vimのインストール
which vim > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Updating apt-get..."
  apt-get update -qq

  # サイズを減らすためRecommendsパッケージがあってもインストールしない
  echo "Installing vim..."
  apt-get install -y -qq --no-install-recommends vim-gnome > /dev/null 2>&1
  apt-get install -y -qq --no-install-recommends language-pack-ja > /dev/null 2>&1

  echo "Configuring locales..."
  dpkg-reconfigure locales > /dev/null 2>&1

  # デフォルトでUTF-8で開く
  echo "Setting default vimrc..."
  echo "set encoding=utf-8" >> ~vagrant/.vimrc
  echo "set fileencodings=utf-8,iso-2022-jp,sjis" >> ~vagrant/.vimrc
  chown vagrant:vagrant ~vagrant/.vimrc

  # サイズ削減
  apt-get clean
fi
