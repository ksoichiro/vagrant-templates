#!/bin/bash

yum install -y wget > /dev/null 2>&1
yum install -y epel-release > /dev/null 2>&1

# Erlang
echo "Configuring Erlang repository..."
pushd /usr/local/src > /dev/null 2>&1
wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm > /dev/null 2>&1
rpm -Uvh erlang-solutions-1.0-1.noarch.rpm > /dev/null 2>&1

# RabbitMQ
echo "Installing RabbitMQ..."
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.6/rabbitmq-server-3.5.6-1.noarch.rpm > /dev/null 2>&1
yum install -y rabbitmq-server-3.5.6-1.noarch.rpm > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to install RabbitMQ."
  exit 1
fi

systemctl start rabbitmq-server > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to start RabbitMQ server."
  exit 1
fi

# execute `rabbitmqctl status` to see status
