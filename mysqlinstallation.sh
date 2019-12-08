#!/bin/bash
sudo apt-get update
sudo apt-get install mysql-server
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow mysql
sudo systemctl start mysql
sudo systemctl enable mysql
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo mysql -e 'update mysql.user set plugin = "mysql_native_password" where user="root"'
sudo mysql -e 'create user "root"@"%" identified by ""'
sudo mysql -e 'grant all privileges on *.* to "root"@"%" with grant option'
sudo systemctl restart mysql