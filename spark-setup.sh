#! /bin/bash
# $1 is node name, e.g. datanode3

set -e

NODE_TYPE=${1::8}	# either 'namenode' or 'datanode'
N_DATANODES=8
NAME_NODE=$2
MYSQL_IP=$3
MONGO_IP=$4
PRIV_PEM_BASE64=$5
HADOOP_HOME=/opt/hadoop
HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
SPARK_HOME=/opt/spark

# namenode doesn't get its own private ip so just use 127.0.0.1 instead
if [[ $NAME_NODE = '' ]]; then
  NAME_NODE=127.0.0.1
fi

# update system
echo "$1 setup script:" updating system...
apt-get -qq update > /dev/null 2>&1
apt-get -qq upgrade > /dev/null 2>&1
echo "$1 setup script:" system updated.

# install Java 8 and PIP3
echo "$1 setup script:" downloading Java 8 JRE and PIP3...
# somehow sometimes the first update is not enough and openjdk would fail, so update again
apt-get -qq update > /dev/null 2>&1
# download first
apt-get -qqd install openjdk-8-jre* python3-pip > /dev/null 2>&1
# install
(
  echo "$1 setup script:" installing Java 8 JRE and PIP3...
  apt-get -qq install openjdk-8-jre* python3-pip > /dev/null 2>&1
  echo "$1 setup script:" finished installing Java 8 JRE and PIP3.
) &
java_install=$!

# download Hadoop and Spark
echo "$1 setup script:" downloading Hadoop 2.7.7...
wget -q https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz -P /tmp > /dev/null 2>&1 &
hadoop_dl=$!
(
  tail --pid=$hadoop_dl -f /dev/null  # wait
  echo "$1 setup script:" downloading Spark 2.4.4...
  wget -q https://www-eu.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz -P /tmp > /dev/null 2>&1
) &
spark_dl=$!

# install Hadoop
(
  tail --pid=$hadoop_dl -f /dev/null  # wait
  echo "$1 setup script:" installing Hadoop...

  # extract tarball
  tar zxvf /tmp/hadoop-* -C /tmp > /dev/null 2>&1
  mv /tmp/hadoop-2.7.7 $HADOOP_HOME

  # update hadoop-env.sh to use $JAVA_HOME as java home
  hadoop_env=$HADOOP_CONF_DIR/hadoop-env.sh
  mv $hadoop_env $hadoop_env.old
  sed 's/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/g' $hadoop_env.old > $hadoop_env
  rm $hadoop_env.old

  # change core-site.xml configuration
  core_site=$HADOOP_CONF_DIR/core-site.xml
  {
    head -n -3 $core_site
    echo "
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://$NAME_NODE:9000/</value>
  </property>
</configuration>"
  } > $core_site.2
  rm $core_site
  mv $core_site.2 $core_site

  # change hdfs-site.xml
  hdfs_site=$HADOOP_CONF_DIR/hdfs-site.xml
  {
    head -n -4 $hdfs_site
    echo "
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>$N_DATANODES</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://${HADOOP_HOME}/hadoop_data/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file://${HADOOP_HOME}/hadoop_data/hdfs/datanode</value>
  </property>
</configuration>"
  } > $hdfs_site.2
  rm $hdfs_site
  mv $hdfs_site.2 $hdfs_site

  # write Hadoop slaves file
  echo "172.31.0.101
  172.31.0.102
  172.31.0.103
  172.31.0.104
  172.31.0.105
  172.31.0.106
  172.31.0.107
  172.31.0.108" > $HADOOP_CONF_DIR/slaves

  # add HDFS as a systemd service
  service="[Unit]
Description=HDFS $NODE_TYPE service
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=$HADOOP_HOME/bin/hdfs $NODE_TYPE
Restart=always

[Install]
WantedBy=multi-user.target
  "
  echo "$service" > $HADOOP_HOME/hdfs-$NODE_TYPE.service
  systemctl -q enable $HADOOP_HOME/hdfs-$NODE_TYPE.service > /dev/null 2>&1

  echo "$1 setup script:" finished installing Hadoop.
) &
hadoop_install=$!

# install Spark
(
  tail --pid=$spark_dl -f /dev/null   # wait
  echo "$1 setup script:" installing Spark...

  # extract tarball
  tar zxvf /tmp/spark-* -C /tmp > /dev/null 2>&1
  mv /tmp/spark-2.4.4-bin-hadoop2.7 $SPARK_HOME

  # configure Spark
  echo "export PYSPARK_PYTHON=/usr/bin/python3" > $SPARK_HOME/conf/spark-env.sh
  echo 'spark.executor.memory 6g' > $SPARK_HOME/conf/spark-defaults.conf

  # add Spark as a systemd service
  if [[ $NODE_TYPE = namenode ]]; then
    SPARK_NODE_TYPE=master
    START_CMD="$SPARK_HOME/sbin/start-master.sh"
  else
    SPARK_NODE_TYPE=slave
    START_CMD="$SPARK_HOME/sbin/start-slave.sh $NAME_NODE:7077"
  fi
  service="[Unit]
Description=Spark $SPARK_NODE_TYPE service
Requires=network-online.target
After=network-online.target

[Service]
Type=forking
ExecStart=$START_CMD
ExecStop=$SPARK_HOME/sbin/stop-$SPARK_NODE_TYPE.sh
Restart=always
  "
  echo "$service" > $SPARK_HOME/spark-$SPARK_NODE_TYPE.service
  if [[ $NODE_TYPE = namenode ]]; then
    echo "
[Install]
WantedBy=multi-user.target
    " >> $SPARK_HOME/spark-$SPARK_NODE_TYPE.service
  fi
  systemctl -q enable $SPARK_HOME/spark-$SPARK_NODE_TYPE.service > /dev/null 2>&1

  echo "$1 setup script:" finished installing Spark.
) &
spark_install=$!

# install pyspark and numpy
(
  # wait
  tail --pid=$spark_dl -f /dev/null
  tail --pid=$java_install -f /dev/null

  echo "$1 setup script:" installing NumPy and PySpark...
  pip3 -q install numpy pyspark
  echo "$1 setup script:" installed NumPy and PySpark.
) &
pip_install=$!

# configure environment variables
echo "$1 setup script: configuring environment variables."
echo "
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=$HADOOP_HOME
export SPARK_HOME=$SPARK_HOME
export PATH=\$PATH:\$JAVA_HOME/bin:\$HADOOP_HOME/bin:\$SPARK_HOME/bin
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" \
  > /etc/profile.d/hadoop-spark.sh

# set up datanode registration service
if [[ $NODE_TYPE = datanode ]]; then
  echo "[Unit]
Description=Datanode registration service
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do curl -X POST http://$NAME_NODE/datanode_register; sleep 10; done'
Restart=always

[Install]
WantedBy=multi-user.target
" > /datanode-register.service
  systemctl enable /datanode-register.service
fi

if [[ $NODE_TYPE = namenode ]]; then
  . namenode-extra-setup.sh
fi

wait
systemctl reboot
