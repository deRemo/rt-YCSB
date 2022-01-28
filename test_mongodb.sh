#!/bin/bash
#Make sure the mongodb binding has been built
#mvn -pl site.ycsb:mongodb-binding -am clean package

if [ -z $1 ]
then
	echo "Need 1 input parameter: either load or run"
	exit -1
fi

if [ "$1" != "run" ] && [ "$1" != "load" ]
then
	echo "Wrong input parameter: either load or run"
	exit -1
fi

CMD_TYPE=""
if [ "$1" == "load" ]
then
	CMD_TYPE=-$1
else
	CMD_TYPE="-t"
fi

/usr/local/jdk-16/bin/java  -classpath $HOME/Repositories/rt-YCSB/mongodb/conf:/home/r.andreoli/Repositories/rt-YCSB/mongodb/target/mongodb-binding-0.18.0-SNAPSHOT.jar:$HOME/.m2/repository/org/apache/htrace/htrace-core4/4.1.0-incubating/htrace-core4-4.1.0-incubating.jar:$HOME/.m2/repository/org/xerial/snappy/snappy-java/1.1.7.1/snappy-java-1.1.7.1.jar:$HOME/.m2/repository/org/hdrhistogram/HdrHistogram/2.1.4/HdrHistogram-2.1.4.jar:$HOME/.m2/repository/org/mongodb/mongo-java-driver/3.11.0/mongo-java-driver-3.11.0.jar:$HOME/.m2/repository/org/codehaus/jackson/jackson-mapper-asl/1.9.4/jackson-mapper-asl-1.9.4.jar:$HOME/.m2/repository/org/codehaus/jackson/jackson-core-asl/1.9.4/jackson-core-asl-1.9.4.jar:$HOME/Repositories/rt-YCSB/core/target/core-0.18.0-SNAPSHOT.jar site.ycsb.Client $CMD_TYPE -db site.ycsb.db.MongoDbClient -s -P ./workloads/workloada -p mongodb.url=mongodb://ravenclaw:27017/ycsb?w=0
