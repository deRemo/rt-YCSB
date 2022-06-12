#!/bin/bash
#Make sure the mongodb binding has been built
#mvn -pl site.ycsb:mongodb-binding -am clean package

usage() { echo "Usage: $0 [-p phase <load|run>] [-u nuser <int>] [-w write-concern <int>] [-t throughput ops/s <int>][-h high-prio users <int>] [-n norm-prio users <int>] [-l low-prio users <int>]" 1>&2; exit -1; }


#defaults
W=1
NUSERS=64
TARGET_THROUGHPUT=""
HPRIO=""
NPRIO=""
LPRIO=""

while getopts ":p:u:w:t:h:n:l:" o; do
    case "${o}" in
		p)
			p=${OPTARG}
			#((p == "load" || p == "run")) || usage
			;;
        u)
            NUSERS=${OPTARG}
            ;;
        w)
            W=${OPTARG}
            ;;
		t) 
			TARGET_THROUGHPUT="-p target=${OPTARG}"
			;;
		h)
			HPRIO="-p highpriority=${OPTARG}"
			;;
		n)
			NPRIO="-p normalpriority=${OPTARG}"
			;;
		l)
			LPRIO="-p lowpriority=${OPTARG}"
			;;
        *)
			echo "Unrecognized option ${o}"
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${p}" ]; then
	echo "-p parameter is mandatory"
    usage
fi

if [ "${p}" != "run" ] && [ "${p}" != "load" ]
then
	echo "Wrong input parameter: either load or run"
	usage
fi



#Convert phase optional arg to ycsb parameter
CMD_TYPE=""
if [ $p == "load" ]
then
	CMD_TYPE=-$p
else
	CMD_TYPE="-t"
fi


#WORKS ON ARMSRV1 ONLY 
#Add this to suppress debug log: -Dlogback.configurationFile=$HOME/Repositories/rt-YCSB/mongodb/src/main/resources/logback.xml
taskset -c 0-94 /usr/local/jdk-16/bin/java -Xms32G -Xmx32G -classpath $HOME/Repositories/rt-YCSB/mongodb/conf:/home/r.andreoli/Repositories/rt-YCSB/mongodb/target/mongodb-binding-0.18.0-SNAPSHOT.jar:$HOME/.m2/repository/org/apache/htrace/htrace-core4/4.1.0-incubating/htrace-core4-4.1.0-incubating.jar:$HOME/.m2/repository/org/xerial/snappy/snappy-java/1.1.7.1/snappy-java-1.1.7.1.jar:$HOME/.m2/repository/org/hdrhistogram/HdrHistogram/2.1.4/HdrHistogram-2.1.4.jar:$HOME/.m2/repository/org/mongodb/mongo-java-driver/3.11.0/mongo-java-driver-3.11.0.jar:$HOME/.m2/repository/org/codehaus/jackson/jackson-mapper-asl/1.9.4/jackson-mapper-asl-1.9.4.jar:$HOME/.m2/repository/org/codehaus/jackson/jackson-core-asl/1.9.4/jackson-core-asl-1.9.4.jar:$HOME/Repositories/rt-YCSB/core/target/core-0.18.0-SNAPSHOT.jar site.ycsb.Client $CMD_TYPE -db site.ycsb.db.MongoDbClient -s        								                                                \
-P ./workloads/workloada -p recordcount=10000 -p operationcount=1000000	-p threadcount=$NUSERS -p measurementtype=timeseries    \
-p mongodb.url=mongodb://10.30.3.34:27017/myDb?w=${W}\&journal=true\&maxPoolSize=300                                            \
-p requestdistribution=zipfian -p fieldlengthdistribution=constant ${TARGET_THROUGHPUT} ${HPRIO} ${NPRIO} ${LPRIO}                                          

#-p timeseries.granularity=1000 

#jvm arguments -XX:MaxGCPauseMillis=20 -Xms32G -Xmx32G
#-XX:+UseZGC
