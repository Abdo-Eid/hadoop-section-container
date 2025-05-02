#!/bin/bash
cd /home/hadoop
echo "Starting Hadoop services..."

# Start SSHD in the background
sudo service ssh start

# Format HDFS if not already formatted
if [ ! -d "/home/hadoop/hdfs/namenode/current" ]; then
  echo "Formatting HDFS namenode..."
  hdfs namenode -format -force -nonInteractive
fi

# Start Hadoop services
echo "Starting HDFS..."

start-dfs.sh

echo "Starting YARN..."
start-yarn.sh

echo "Hadoop services started."
exec bash
