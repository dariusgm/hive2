FROM williamyeh/java7
MAINTAINER https://github.com/dariusgm
# Need to update for ssh
RUN apt-get update && \
  apt-get install -y bash wget tar ssh

# Fetch Hadoop and Unpack & Fetch Hive and Unpack
WORKDIR /usr/local
RUN wget -qq http://mirror.netcologne.de/apache.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz && \
  tar xf hadoop-2.7.2.tar.gz  && \
  wget -qq http://mirror.softaculous.com/apache/hive/hive-2.0.0/apache-hive-2.0.0-bin.tar.gz && \
  tar xf apache-hive-2.0.0-bin.tar.gz

WORKDIR /usr/local/hadoop-2.7.2/etc/hadoop

# Remove Templates
RUN rm -f core-site.xml hadoop-env.sh hdfs-site.xml mapred-site.xml yarn-site.xml

# Install core-site Config
ADD core-site.xml core-site.xml
ADD hadoop-env.sh hadoop-env.sh
ADD hdfs-site.xml hdfs-site.xml
ADD mapred-site.xml mapred-site.xml
ADD yarn-site.xml yarn-site.xml

# Set Env

ENV HADOOP_HEAPSIZE=8192
ENV HADOOP_HOME=/usr/local/hadoop-2.7.2
ENV HIVE_HOME=/usr/local/apache-hive-2.0.0-bin
ENV PATH=$HIVE_HOME:$HADOOP_HOME:$PATH
ENV JAVA_HOME=/usr/


# Setup SSH
WORKDIR /root
RUN mkdir .ssh
RUN cat /dev/zero | ssh-keygen -q -N "" > /dev/null && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys

ADD hive-site.xml /usr/local/apache-hive-2.0.0-bin/conf/hive-site.xml

# Format HFS
RUN /usr/local/hadoop-2.7.2/bin/hdfs namenode -format -nonInteractive

# Create Hive Metastore
RUN /usr/local/apache-hive-2.0.0-bin/bin/schematool -initSchema -dbType derby

# Hadoop Resource Manager
EXPOSE 8088

# Hadoop NameNode
EXPOSE 50070

# Hadoop DataNode
EXPOSE 50075

# Hive WebUI
EXPOSE 10002

# Hive Master
EXPOSE 10000

# Start sshd, allow ssh connection for pseudo distributed mode, yarn, datanode and namenode, hive2 - move this to docker compose.
ENTRYPOINT service ssh start && \
  ssh-keyscan localhost > /root/.ssh/known_hosts && \
  ssh-keyscan ::1 >> /root/.ssh/known_hosts && \
  ssh-keyscan 0.0.0.0 >> /root/.ssh/known_hosts && \
  /usr/local/hadoop-2.7.2/sbin/start-yarn.sh && \
  /usr/local/hadoop-2.7.2/sbin/start-dfs.sh && \
  /usr/local/apache-hive-2.0.0-bin/bin/hive --service hiveserver2
