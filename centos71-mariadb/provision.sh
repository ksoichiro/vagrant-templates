#!/bin/bash

cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

yum install -y MariaDB-server MariaDB-client #> /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to install MariaDB."
  exit 1
fi

systemctl start mysql
if [ $? -ne 0 ]; then
  echo "Failed to start MariaDB."
  exit 1
fi

cat > /tmp/init.sql <<EOF
delete from mysql.user where User = 'root';
grant all privileges on *.* to root@'%' identified by 'test' with grant option;
flush privileges;
EOF
mysql -uroot < /tmp/init.sql > /dev/null 2>&1
#sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

systemctl enable mariadb
systemctl restart mariadb
