#! /bin/bash

SQOOP_HOME=/opt/sqoop
CONTROL_SERVER_HOME=/opt/control-server

# install Sqoop and its MySQL connector
# download
(
    tail --pid=$spark_dl -f /dev/null    # wait
    echo "namenode extra setup script:" downloading Sqoop 1.4.7 and MySQL connector...
    wget -q https://www-eu.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -P /tmp > /dev/null 2>&1
    wget http://ftp.ntu.edu.tw/MySQL/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz -P /tmp > /dev/null 2>&1
) &
sqoop_dl=$!
# install
(
    tail --pid=$sqoop_dl -f /dev/null   # wait
    echo "namenode extra setup script:" installing Sqoop 1.4.7 and MySQL connector...
    tar zxvf /tmp/sqoop-* -C /tmp > /dev/null
    mv /tmp/sqoop-1.4.7.bin__hadoop-2.6.0 $SQOOP_HOME
    tar zxvf /tmp/mysql-* -C /tmp > /dev/null
    mv /tmp/mysql-connector-java-5.1.48/*.jar $SQOOP_HOME/lib/
    echo "namenode extra setup script:" installed Sqoop 1.4.7 and MySQL connector.
) &
sqoop_install=$!

# install Java 8 JDK, MongoDB tools, and Flask
# download
(
    # wait
    tail --pid=$java_install -f /dev/null
    tail --pid=$sqoop_dl -f /dev/null

    echo "namenode extra setup script:" downloading Java 8 JDK, MongoDB tools, and Flask...
    wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - > /dev/null 2>&1
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" \
        > /etc/apt/sources.list.d/mongodb-org-4.2.list
    apt-get -qq update > /dev/null 2>&1
    apt-get -qqd install mongodb-org-tools openjdk-8-jdk python3-flask > /dev/null 2>&1
) &
extra_apt_dl=$!
# install
(
    tail --pid=$extra_apt_dl -f /dev/null   # wait
    echo "namenode extra setup script:" installing Java 8 JDK, MongoDB tools, and Flask...
    apt-get -qq install mongodb-org-tools openjdk-8-jdk python3-flask > /dev/null 2>&1
    echo "namenode extra setup script:" installed Java 8 JDK, MongoDB tools, and Flask.
) &
extra_apt_install=$!

# install Spark control server
(
    # wait
    tail --pid=$extra_apt_install -f /dev/null
    tail --pid=$pip_install -f /dev/null

    echo "namenode extra setup script:" installing Spark control server...

    pip3 -q install fabric flask-cors
    tar zxvf /home/ubuntu/control-server.tgz -C /tmp > /dev/null
    mv /tmp/control-server $CONTROL_SERVER_HOME
    chmod a+x $CONTROL_SERVER_HOME/control-server

    # move instance private key
    mkdir -p /etc/opt/control-server
    mv /home/ubuntu/my-hadoop-key.pem /etc/opt/control-server/

    # set MySQL and MongoDB IP addresses
    echo $MYSQL_IP > /etc/opt/control-server/mysql-ip
    echo $MONGO_IP > /etc/opt/control-server/mongo-ip

    # add Spark control server as a systemd service
    service="[Unit]
Description=Spark control server
Requires=network-online.target spark-master.service
After=network-online.target spark-master.service

[Service]
Type=simple
ExecStart=/opt/control-server/control-server
Restart=always

[Install]
WantedBy=multi-user.target
"
    echo "$service" > $CONTROL_SERVER_HOME/control-server.service
    systemctl -q enable $CONTROL_SERVER_HOME/control-server.service > /dev/null

    echo "namenode extra setup script:" installed Spark control server.
) &
control_server_install=$!

# configure environment variables
echo "
export SQOOP_HOME=$SQOOP_HOME
export CONTROL_SERVER_HOME=$CONTROL_SERVER_HOME
export PATH=\$PATH:\$SQOOP_HOME/bin:\$CONTROL_SERVER_HOME
" > /etc/profile.d/namenode-extra.sh

# format HDFS
wait $hadoop_install
wait $java_install
echo "namenode setup script:" formatting HDFS...
$HADOOP_HOME/bin/hdfs --loglevel ERROR namenode -format hadoop > /dev/null
echo "namenode setup script:" formatted HDFS.
