#!/bin/bash
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable


# Variables
source password
echo $scm_password
db_root_password="${1}"
#

yum remove mariadb-libs -y
yum clean all

cp mysql-community.repo /etc/yum.repos.d/
yum install -y mysql-server wget 
systemctl stop mysqld
mkdir -p /root/mysqlbk/
#mv /var/lib/mysql/ib_logfile0 /root/mysqlbk/
#mv /var/lib/mysql/ib_logfile1 /root/mysqlbk/
cp my.cnf /etc/my.cnf
systemctl start mysqld
sleep 10s
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

echo "Start creation of databases for scm, amon, rmon, hive, sentry, nav, navms"
mysql --user=root --password=${db_root_password}<<_EOF_
  create database scm DEFAULT CHARACTER SET utf8;
  grant all on scm.* TO 'scm'@'%' IDENTIFIED BY '${scm_password}';
  create database amon DEFAULT CHARACTER SET utf8;
  grant all on amon.* TO 'amon'@'%' IDENTIFIED BY '${amon_password}';
  create database rman DEFAULT CHARACTER SET utf8;
  grant all on rman.* TO 'rman'@'%' IDENTIFIED BY '${rmon_password}';
  create database hivemetastore DEFAULT CHARACTER SET utf8;
  grant all on hivemetastore.* TO 'hive'@'%' IDENTIFIED BY '${hive_password}';
  create database sentry DEFAULT CHARACTER SET utf8;
  grant all on sentry.* TO 'sentry'@'%' IDENTIFIED BY '${sentry_password}';
  create database navaudit DEFAULT CHARACTER SET utf8;
  grant all on navaudit.* TO 'navaudit'@'%' IDENTIFIED BY '${nav_password}';
  create database navmetastore DEFAULT CHARACTER SET utf8;
  grant all on navmetastore.* TO 'navmetastore'@'%' IDENTIFIED BY '${navms_password}';
  create database oozie DEFAULT CHARACTER SET utf8;
  grant all on oozie.* TO 'oozie'@'%' IDENTIFIED BY '${oozie_password}';
  create database hue DEFAULT CHARACTER SET utf8;
  grant all on hue.* TO 'hue'@'%' IDENTIFIED BY '${hue_password}';
  create database arcadia DEFAULT CHARACTER SET utf8;
  grant all on arcadia.* TO 'arcadia'@'%' IDENTIFIED BY '${arcadia_password}';
  FLUSH PRIVILEGES;
_EOF_

/usr/share/cmf/schema/scm_prepare_database.sh mysql scm scm "OQ319PngYUD3+anMD6TTOYI+wPNvyfzJyJHly6HZupk="

wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
tar zxvf mysql-connector-java-5.1.40.tar.gz
sudo mkdir -p /usr/share/java
sudo cp mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar
chmod 755 /usr/share/java/mysql-connector-java.jar
mkdir -p /var/lib/oozie/
chmod 755 /var/lib/oozie
sudo cp mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /var/lib/oozie/mysql-connector-java.jar
chmod 755 /var/lib/oozie/mysql-connector-java.jar








