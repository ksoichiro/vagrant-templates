#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq > /dev/null 2>&1
apt-get install -y python-software-properties software-properties-common > /dev/null 2>&1
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db > /dev/null 2>&1
add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.1/ubuntu precise main' > /dev/null 2>&1
apt-get update -qq > /dev/null 2>&1
apt-get install -y mariadb-server > /dev/null 2>&1
cat > /tmp/init.sql <<-EOF
delete from mysql.user where User = 'root';
grant all privileges on *.* to root@'%' identified by 'test' with grant option;
flush privileges;
EOF
mysql -uroot < /tmp/init.sql > /dev/null 2>&1
sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
service mysql restart
