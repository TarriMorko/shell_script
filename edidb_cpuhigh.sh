#!/bin/sh
#
#
while (true); do
    sleep 1
    vmstat -t | grep -v free | grep -v memory | awk '{print $0}' > vmstat.txt
    sy=$( awk '{print $15}' vmstat.txt )   ## 這裡要調
    if [ "$sy" -gt 0 ]; then                    ## 大於多少要做
        echo "sy 大於0"                           ## 做  perfpmr.sh -x trace.sh 5
        echo $sy
    fi
done
