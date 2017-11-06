#!/bin/bash
#
#
# qmanager 啟動狀態下才查得到

QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g')

for qmgr in $QMGRS; do
    echo "qmgr: $qmgr"
    LISTENERS=$(echo "DISPLAY LISTENER(*)"  | runmqsc $qmgr -e | grep -oP '(?<=LISTENER\().*(?=\))' | grep -v SYSTEM )
    echo $LISTENERS

    for listener in $LISTENERS; do
        port_of_listener=$(echo "DISPLAY LISTENER(${listener})" | runmqsc $qmgr -e |  grep -oP '(?<=PORT\().*(?=\))')
        echo "在 Qmanager: $qmgr 裡面的 listener: $listener 開這個 port $port_of_listener "

        netstat -tunel  | grep LISTEN | grep $port_of_listener -q
        if [ $? -eq 0 ]; then
            echo "有開啦"
        else
            echo "start LISTENER" | runmqsc $qmgr
        fi
    done

done 
