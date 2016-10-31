#!/bin/bash
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable


# Variables
db_root_password="${1}"
#

yum remove mariadb-libs -y
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


mysql --user=root --password=${db_root_password}<<_EOF_
  create database scm DEFAULT CHARACTER SET utf8;
  grant all on scm.* TO 'scm'@'%' IDENTIFIED BY 'Jd0l9qHSU4WCsmbftcXiUyYjwmS+TAJPjnuHX8MISME=';
  create database amon DEFAULT CHARACTER SET utf8;
  grant all on amon.* TO 'amon'@'%' IDENTIFIED BY 'BOQNZu22aRPWSgJvf/w7k5mbSNheFCcMwkRBCV4QCmY=';
  create database rmon DEFAULT CHARACTER SET utf8;
  grant all on rmon.* TO 'rmon'@'%' IDENTIFIED BY 'ulkZ6jLsymBkj/sZiol2ZWXnYAK/W4XG93Divu7c2qI=';
  create database metastore DEFAULT CHARACTER SET utf8;
  grant all on metastore.* TO 'hive'@'%' IDENTIFIED BY 'pekgKENcdh1Ej2kcERaFTYcaPZgDPyevp66fV07OnTk=';
  create database sentry DEFAULT CHARACTER SET utf8;
  grant all on sentry.* TO 'sentry'@'%' IDENTIFIED BY 'Rn8dIr3KbEQpfjoiUeiMBu5ufZsNVEFY4WqDOm6KSNE=';
  create database nav DEFAULT CHARACTER SET utf8;
  grant all on nav.* TO 'nav'@'%' IDENTIFIED BY '15BpPxWCitVLDN5yKfqJ/iUciVk9yPyQiJLKUeyXOL4=';
  create database navms DEFAULT CHARACTER SET utf8;
  grant all on navms.* TO 'navms'@'%' IDENTIFIED BY 'LrNAbS0cw4bHOqEfo2Y7Mf3ByBeE2iBz2rMDpddqZ5U=';
  FLUSH PRIVILEGES;
_EOF_



wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
tar zxvf mysql-connector-java-5.1.40.tar.gz
sudo mkdir -p /usr/share/java
sudo cp mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar