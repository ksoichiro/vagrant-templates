#!/usr/bin/env bash

SEQ=$1
NODE_ADDRESS=$2

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq > /dev/null 2>&1

echo "Installing required softwares..."
apt-get install -y python-software-properties software-properties-common > /dev/null 2>&1

echo "Installing MariaDB..."
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db > /dev/null 2>&1
add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.1/ubuntu precise main' > /dev/null 2>&1
apt-get update -qq > /dev/null 2>&1
apt-get install -y mariadb-server > /dev/null 2>&1

echo "Configuring MariaDB..."
cat > /tmp/init.sql <<-EOF
delete from mysql.user where User = 'root';
grant all privileges on *.* to root@'%' identified by 'test' with grant option;
flush privileges;
create database test;
EOF
mysql -uroot < /tmp/init.sql > /dev/null 2>&1
sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

cat > /etc/mysql/conf.d/mariadb.cnf <<-EOF
# MariaDB-specific config file.
# Read by /etc/mysql/my.cnf

[client]
# Default is Latin1, if you need UTF-8 set this (also in server section)
#default-character-set = utf8

[mysqld]
#
# * Character sets
#
# Default is Latin1, if you need UTF-8 set all this (also in client section)
#
#character-set-server  = utf8
#collation-server      = utf8_general_ci
#character_set_server   = utf8
#collation_server       = utf8_general_ci

general-log
general-log-file=queries.log
log-output=file

wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_node_address=${NODE_ADDRESS}
wsrep_cluster_address='gcomm://192.168.33.11,192.168.33.12,192.168.33.13'
binlog_format=ROW
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_doublewrite=1
query_cache_size=0
wsrep_on=ON
EOF

# One more step, 2nd and 3rd db must have /etc/mysql/debian.cnf from 1st.

service mysql restart #--wsrep-new-cluster
