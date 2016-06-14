# hive2
This Dockerfile allows you to install Hadoop and Hive in one container.


Build Image
===========

docker build -t hive .

Run container
=============
docker run -it -p 8088:8088 -p 50070:50070 -p 50075:50075 -p 10000:10000 -p 10002:10002 -p 7077:7077 -p 7088:7088 hive
