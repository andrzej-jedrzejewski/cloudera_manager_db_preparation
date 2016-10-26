#!/bin/bash
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable


# Variables
db_root_password="${1}"
#


#sudo yum remove mariadb-libs



yum clean all

cp mysql-community.repo /etc/yum.repos.d/
yum install -y mysql-server wget 
systemctl stop mysqld
mkdir -p /root/mysqlbk/
mv /var/lib/mysql/ib_logfile0 /root/mysqlbk/
mv /var/lib/mysql/ib_logfile1 /root/mysqlbk/
cp my.cnf /etc/my.cnf
systemctl start mysqld
sleep 2m
sudo /sbin/chkconfig mysqld on 


echo "Start mysql secure installation proccess"

mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_

echo "Secure installation proccess has been done"

wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
tar zxvf mysql-connector-java-5.1.40.tar.gz
sudo mkdir -p /usr/share/java
sudo cp mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar