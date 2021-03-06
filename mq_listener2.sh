#!/bin/bash
#
#
# qmanager 啟動狀態下才查得到
##	Global Variables for sending SMS Alarm

## Variables and functions for logging
_DEBUG="on"
LOGFILENAME="mq_listener2.log"

DEBUG() {
    [ "$_DEBUG" == "on" ] && echo "$(date +"%Y-%m-%d %H:%M:%S") $@" || :
}

writelog() {
    # Creat SMS Alarm
    ACCOUNT=AA34567
    FILENAME_PRIFIX=${ACCOUNT}$(date +%Y%s)
    TXT_FILE="${FILENAME_PRIFIX}.txt"
    END_FILE="${FILENAME_PRIFIX}.end"
    TXT_MODE="C"
    PHONE_NUMBER="0900123456 0900345988"
    log_message=$@
    echo "$(date +"%Y-%m-%d %H:%M:%S") ${log_message}" | tee -a ${LOGFILENAME}
    echo "" >$END_FILE
    echo $@ >$TXT_FILE
    echo $TXT_MODE >>$TXT_FILE
    for phone in $PHONE_NUMBER; do
        echo $phone >>$TXT_FILE
    done
    # exit 0
}

QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g')

for qmgr in $QMGRS; do
    DEBUG "qmgr: $qmgr"
    LISTENERS=$(echo "DISPLAY LISTENER(*)" |
        runmqsc $qmgr -e |
        grep -oP '(?<=LISTENER\().*(?=\))' |
        grep -v SYSTEM)

    DEBUG LISTENERS: $LISTENERS

    for listener in $LISTENERS; do
        port_of_listener=$(echo "DISPLAY LISTENER(${listener})" |
            runmqsc $qmgr -e |
            grep -oP '(?<=PORT\().*(?=\))')

        DEBUG "在 Qmanager: $qmgr 裡面的 listener: $listener 開這個 port $port_of_listener "

        netstat -tunel | grep LISTEN | grep $port_of_listener -q

        if [ $? -eq 0 ]; then
            DEBUG "Listener : $listener is running"
        else
            echo "start listener($listener)" | runmqsc $qmgr
            writelog "Start Listener : $listener with port $port_of_listener in QMGR $qmgr"
            sleep 1
        fi
    done

done
