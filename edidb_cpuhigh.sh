#!/bin/sh
#
#

LOGFILENAME="edidb_cpuhigh.log"

echo "$(date +"%Y-%m-%d %H:%M:%S")" script start >>${LOGFILENAME}

while (true); do
    sleep 1
    idle=$(vmstat -t | tail -n 1 | tee -a ${LOGFILENAME} | awk '{print $(NF-4)}')
    if [ $idle -lt 5 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S")" trace start >>${LOGFILENAME}

        ./perfpmr.sh -x trace.sh 5

        echo "$(date +"%Y-%m-%d %H:%M:%S")" trace done >>${LOGFILENAME}
        exit 0
    fi
done