#!/usr/bin/env bash

SERVER_ID=$1
MASTER_ADDRESS=$2

MARIADB_ADMIN_USER="root"
MARIADB_ADMIN_PASSWORD="test"
MARIADB_REPLICATION_USER=replication_user
MARIADB_REPLICATION_PASSWORD=password
MASTER_DUMP=/vagrant/.master.dump
DB_APP=test

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
cat > /tmp/init.sql <<EOF
delete from mysql.user where User = '${MARIADB_ADMIN_USER}';
grant all privileges on *.* to ${MARIADB_ADMIN_USER}@'%' identified by '${MARIADB_ADMIN_PASSWORD}' with grant option;
flush privileges;
create database ${DB_APP};
EOF
mysql -uroot < /tmp/init.sql > /dev/null 2>&1
sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

cat > /etc/mysql/conf.d/mariadb.cnf <<-EOF
# MariaDB-specific config file.
# Read by /etc/mysql/my.cnf

[client]
# Default is Latin1, if you need UTF-8 set this (also in server section)
default-character-set = utf8

[mysqld]
#
# * Character sets
#
# Default is Latin1, if you need UTF-8 set all this (also in client section)
#
character-set-server  = utf8
collation-server      = utf8_general_ci
character_set_server   = utf8
collation_server       = utf8_general_ci

general-log
general-log-file=queries.log
log-output=file

server_id=${SERVER_ID}
default_storage_engine=InnoDB
EOF

mysql -u${MARIADB_ADMIN_USER} -p${MARIADB_ADMIN_PASSWORD} < ${MASTER_DUMP}

MASTER_LOG_FILE=`mysql -h ${MASTER_ADDRESS} -u${MARIADB_ADMIN_USER} -p${MARIADB_ADMIN_PASSWORD} -e"show master status\G" | grep "File:" | sed -e "s/^.*: //"`
MASTER_LOG_POS=`mysql -h ${MASTER_ADDRESS} -u${MARIADB_ADMIN_USER} -p${MARIADB_ADMIN_PASSWORD} -e"show master status\G" | grep "Position:" | sed -e "s/^.*: //"`

cat > /tmp/start-slave.sql <<EOF
CHANGE MASTER TO
  MASTER_HOST='${MASTER_ADDRESS}',
  MASTER_USER='${MARIADB_REPLICATION_USER}',
  MASTER_PASSWORD='${MARIADB_REPLICATION_PASSWORD}',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='${MASTER_LOG_FILE}',
  MASTER_LOG_POS=${MASTER_LOG_POS},
  MASTER_CONNECT_RETRY=10;
EOF

service mysql start
mysql -u${MARIADB_ADMIN_USER} -p${MARIADB_ADMIN_PASSWORD} < /tmp/start-slave.sql > /dev/null 2>&1

service mysql restart
