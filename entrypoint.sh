#!/bin/bash
#
# Entrypoint for the Hadoop pseudo-distributed single-node container.
# Formats the NameNode on first boot, then starts the HDFS and YARN
# daemons and keeps the container alive.
#
set -e

export HADOOP_HOME=/opt/hadoop-3.3.6
export HADOOP_CONF_DIR=/opt/hadoop-3.3.6/etc/hadoop

# Format the NameNode only once (on first boot / empty data dir).
if [ ! -d /data/dfs/name/current ]; then
  echo ">>> Formatting NameNode..."
  hdfs namenode -format -force -nonInteractive
fi

echo ">>> Starting NameNode..."
hdfs --daemon start namenode
echo ">>> Starting DataNode..."
hdfs --daemon start datanode
echo ">>> Starting ResourceManager..."
yarn --daemon start resourcemanager
echo ">>> Starting NodeManager..."
yarn --daemon start nodemanager

echo ">>> Hadoop cluster is up."
echo "(NameNode UI: http://localhost:9870  ResourceManager UI: http://localhost:8088)"

# Keep the container alive.
tail -f /dev/null
