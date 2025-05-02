# Use the official Ubuntu base image
FROM ubuntu:20.04

# ensure unattended package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo ssh openssh-server \
    openjdk-11-jdk-headless \
    python-is-python3 python3-pip \
    nano curl dos2unix && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python mrjob package
RUN pip3 install --no-input mrjob

# Set HADOOP_HOME environment variable
ENV HADOOP_HOME=/home/hadoop/hadoop

# Set other environment variables for Hadoop
ENV PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH \
    HDFS_NAMENODE_USER=hadoop \
    HDFS_DATANODE_USER=hadoop \
    HDFS_SECONDARYNAMENODE_USER=hadoop \
    YARN_NODEMANAGER_USER=hadoop \
    YARN_RESOURCEMANAGER_USER=hadoop \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64


# add hadoop user Allow root, hadoop to sudo without password
RUN echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    useradd -ms /bin/bash hadoop && echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create Hadoop directory inside the hadoop user's home
RUN mkdir -p /home/hadoop/hadoop /home/hadoop/hdfs/{namenode,datanode}

# Option 1: Copy local Hadoop binary (preferred if available)
# COPY hadoop-3.4.1.tar.gz /tmp/hadoop.tar.gz

# Option 2: Download Hadoop binary (uncomment if local copy isn't available)
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz -O /tmp/hadoop.tar.gz


# Create directories, extract Hadoop, clean up and set ownership
RUN tar -xzvf /tmp/hadoop.tar.gz -C /home/hadoop/hadoop --strip-components=1 && \
    rm /tmp/hadoop.tar.gz && \
    chown -R hadoop:hadoop /home/hadoop/hadoop && \
    chown -R hadoop:hadoop /home/hadoop/hdfs

# Hadoop configuration
COPY conf/core-site.xml conf/hdfs-site.xml conf/mapred-site.xml conf/yarn-site.xml /home/hadoop/hadoop/etc/hadoop/

# Update hadoop-env.sh for the hadoop user
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh && \
    echo "export HADOOP_CLASSPATH+=\" \$HADOOP_HOME/lib/*.jar\"" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh

# Create SSH folder for hadoop user
RUN mkdir -p /home/hadoop/.ssh && \
    chmod 700 /home/hadoop/.ssh && \
    ssh-keygen -t rsa -P '' -f /home/hadoop/.ssh/id_rsa && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /home/hadoop/.ssh && \
    chmod 600 /home/hadoop/.ssh/authorized_keys


# Expose necessary ports
EXPOSE 9870 8088 9000 22

# Copy start.sh as a separate file in a better location
COPY start.sh /usr/local/bin/start-hadoop

# Set the correct permissions and ownership
RUN chmod +x /usr/local/bin/start-hadoop && \
chown hadoop:hadoop /usr/local/bin/start-hadoop

# Switch to the hadoop user to run the rest of the commands
USER hadoop

# Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/start-hadoop"]