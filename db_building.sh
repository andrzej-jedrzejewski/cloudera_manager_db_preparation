#!/bin/bash
#sudo yum remove mariadb-libs

yum clean all

cp mysql-community.repo /etc/yum.repos.d/
yum install -y mysql-server wget 
systemctl stop mysqld
mkdir -p /root/mysqlbk/
mv /var/lib/mysql/ib_logfile0 /root/mysqlbk/
mv /var/lib/mysql/ib_logfile1 /root/mysqlbk/
cp my.cnf /etc/my.cnf
systemctl stop start
sudo /sbin/chkconfig mysqld on 


echo "Start mysql secure installation proccess"
mysql_secure_installation <<EOF

y
secret
secret
y
y
y
y
EOF

echo "Secure installation proccess has been done"

wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
tar zxvf mysql-connector-java-5.1.40.tar.gz
sudo mkdir -p /usr/share/java
sudo cp mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar