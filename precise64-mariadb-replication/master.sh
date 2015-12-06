#!/usr/bin/env bash

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
if [ $? -ne 0 ]; then
  echo "Failed to install MariaDB server."
  exit 1
fi

echo "Configuring MariaDB..."
sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
service mysql start > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to start MariaDB"
  exit 1
fi
cat > /tmp/init.sql <<EOF
delete from mysql.user where User = '${MARIADB_ADMIN_USER}';
grant all privileges on *.* to ${MARIADB_ADMIN_USER}@'%' identified by '${MARIADB_ADMIN_PASSWORD}' with grant option;
grant replication slave on *.* to ${MARIADB_REPLICATION_USER}@'%' identified by '${MARIADB_REPLICATION_PASSWORD}';
flush privileges;
create database ${DB_APP};
EOF
mysql -uroot < /tmp/init.sql > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to configure MariaDB"
  exit 1
fi

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

log-bin
server_id=1
binlog_format=ROW
default_storage_engine=InnoDB
EOF
service mysql restart > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to restart MariaDB"
  exit 1
fi

mysqldump -u${MARIADB_ADMIN_USER} -p${MARIADB_ADMIN_PASSWORD} ${DB_APP} > ${MASTER_DUMP} 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to dump database"
  exit 1
fi
