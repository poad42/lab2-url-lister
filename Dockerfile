# Hadoop pseudo-distributed cluster on Ubuntu 26.04
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# --- System dependencies ----------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
      openjdk-11-jdk-headless \
      python3 python3-minimal \
      make \
      curl \
      procps \
      openssh-client \
      ca-certificates \
      && rm -rf /var/lib/apt/lists/*

# --- Hadoop 3.3.6 -------------------------------------------------------
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz \
      -o /tmp/hadoop.tar.gz \
 && tar xzf /tmp/hadoop.tar.gz -C /opt \
 && rm -f /tmp/hadoop.tar.gz

ENV HADOOP_HOME=/opt/hadoop-3.3.6
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
# Create python -> python3 symlink for scripts using "#!/usr/bin/env python"
RUN ln -sf /usr/bin/python3 /usr/bin/python

# --- Configuration -----------------------------------------------------
COPY conf/core-site.xml conf/hdfs-site.xml conf/yarn-site.xml conf/mapred-site.xml $HADOOP_CONF_DIR/

RUN mkdir -p /data/dfs/name /data/dfs/data /lab

WORKDIR /lab

# --- Entrypoint --------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8020 9870 8088 9000

ENTRYPOINT ["/entrypoint.sh"]
