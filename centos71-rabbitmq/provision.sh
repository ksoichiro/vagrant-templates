#!/bin/bash

yum install -y wget > /dev/null 2>&1
yum install -y epel-release > /dev/null 2>&1

# Erlang
pushd /usr/local/src > /dev/null 2>&1
wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
#yum install -y esl-erlang
#if [ $? -ne 0 ]; then
#  echo "Failed to install Erlang."
#  exit 1
#fi

# RabbitMQ
#rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
#yum install rabbitmq-server-3.5.6-1.noarch.rpm

wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.6/rabbitmq-server-3.5.6-1.noarch.rpm > /dev/null 2>&1
yum install -y rabbitmq-server-3.5.6-1.noarch.rpm
if [ $? -ne 0 ]; then
  echo "Failed to install RabbitMQ."
  exit 1
fi

systemctl start rabbitmq-server
if [ $? -ne 0 ]; then
  echo "Failed to start RabbitMQ server."
  exit 1
fi

# execute `rabbitmqctl status` to see status
