#!/bin/sh
#
#
while ( true ); do
    sleep 1
    idle=$(vmstat -t | tail -n 1 | tee -a vmstat.log | awk '{print $(NF-4)}')
    if [ $idle -lt 10 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S")" trace start >> vmstat.log
        echo ">>>>${idle}<<<<"
        echo "$(date +"%Y-%m-%d %H:%M:%S")" trace done >> vmstat.log
        exit 0
    fi
done
