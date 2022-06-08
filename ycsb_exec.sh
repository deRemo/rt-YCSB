#!/bin/bash
#Make sure the mongodb binding has been built
#mvn -pl site.ycsb:mongodb-binding -am clean package

if [ -z $1 ]
then
	echo "usage: $0 load|run [nusers] [target_throughput]"
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

NUSERS=60
if [ ! -z "$2" ]
then
	NUSERS=$2
fi

W="1"
if [ ! -z "$3" ]
then
    W=$3
fi

TARGET_THROUGHPUT=""
if [ ! -z "$4" ]
then
	TARGET_THROUGHPUT="-p target=$4"
fi

echo $W
#WORKS ON ARMSRV1 ONLY 
#Add this to suppress debug log: -Dlogback.configurationFile=$HOME/Repositories/rt-YCSB/mongodb/src/main/resources/logback.xml
taskset -c 0-70 /usr/local/jdk-16/bin/java -Xms32G -Xmx32G -classpath $HOME/Repositories/rt-YCSB/mongodb/conf:/home/r.andreoli/Repositories/rt-YCSB/mongodb/target/mongodb-binding-0.18.0-SNAPSHOT.jar:$HOME/.m2/repository/org/apache/htrace/htrace-core4/4.1.0-incubating/htrace-core4-4.1.0-incubating.jar:$HOME/.m2/repository/org/xerial/snappy/snappy-java/1.1.7.1/snappy-java-1.1.7.1.jar:$HOME/.m2/repository/org/hdrhistogram/HdrHistogram/2.1.4/HdrHistogram-2.1.4.jar:$HOME/.m2/repository/org/mongodb/mongo-java-driver/3.11.0/mongo-java-driver-3.11.0.jar:$HOME/.m2/repository/org/codehaus/jackson/jackson-mapper-asl/1.9.4/jackson-mapper-asl-1.9.4.jar:$HOME/.m2/repository/org/codehaus/jackson/jackson-core-asl/1.9.4/jackson-core-asl-1.9.4.jar:$HOME/Repositories/rt-YCSB/core/target/core-0.18.0-SNAPSHOT.jar site.ycsb.Client $CMD_TYPE -db site.ycsb.db.MongoDbClient -s        								\
-P ./workloads/workloada                                            \
-p recordcount=10000                                               \
-p operationcount=1000000										\
-p threadcount=$NUSERS                                               \
-p measurementtype=raw         								\
-p mongodb.url=mongodb://10.30.3.34:27017/myDb?w=${W}\&maxPoolSize=300                             \
-p requestdistribution=zipfian                                  \
-p fieldlengthdistribution=constant                             \
${TARGET_THROUGHPUT}
#-p target=20000
#-p clientpriority=-20                                          \
#-p target=15000                                               

#-p timeseries.granularity=1000 

#jvm arguments -XX:MaxGCPauseMillis=20 -Xms32G -Xmx32G
#-XX:+UseZGC
