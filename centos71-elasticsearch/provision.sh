#!/bin/bash

# JDK
echo "Installing JDK..."
yum install -y java-1.8.0-openjdk-devel > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to install JDK."
  exit 1
fi

# Elasticsearch
echo "Installing Elasticsearch..."
cat > /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch-1.7]
name=Elasticsearch repository for 1.7.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.7/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF
yum install -y elasticsearch > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to install Elasticsearch."
  exit 1
fi

mkdir /usr/share/elasticsearch/config
cp /etc/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config
sed -i -e "s/#http.port: 9200/http.port: 9200/" /usr/share/elasticsearch/config/elasticsearch.yml

systemctl restart elasticsearch > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to start Elasticsearch."
  exit 1
fi
