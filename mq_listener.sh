#!/bin/bash
#
#

##	Global Variables for sending SMS Alarm
ACCOUNT=AA34567
FILENAME_PRIFIX=${ACCOUNT}$(date +%Y%s)
TXT_FILE="${FILENAME_PRIFIX}.txt"
END_FILE="${FILENAME_PRIFIX}.end"
TXT_MODE="C"
PHONE_NUMBER="0900123456 0900345988"

## Variables and functions for logging
_DEBUG="off"
LOGFILENAME="mq_listener.log"

DEBUG() {
    [ "$_DEBUG" == "on" ] && echo "$(date +"%Y-%m-%d %H:%M:%S") $@" || :
}

writelog() {
    # Creat SMS Alarm
    log_message=$@
    echo "$(date +"%Y-%m-%d %H:%M:%S") ${log_message}" | tee -a ${LOGFILENAME}
    echo "" >$END_FILE
    echo $@ >$TXT_FILE
    echo $TXT_MODE >>$TXT_FILE
    for phone in $PHONE_NUMBER; do
        echo $phone >>$TXT_FILE
    done
    exit 0
}

QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g')

for qmgr in $QMGRS; do
    DEBUG "現在在 $qmgr 裡面"
    listeners=$(echo "DISPLAY LISTENER(*)" | runmqsc $qmgr |
        grep LISTENER |
        grep -v DISPLAY |
        grep -o "(.*)" |
        sed -e "s/(//g" |
        sed -e "s/)//g")

    if [ "${listeners}" = "" ]; then
        DEBUG "qmgr $qmgr 好像沒有 listner"
        continue
    fi

    for listener in $listeners; do
        status=$(echo "DISPLAY LSSTATUS($listener)" |
            runmqsc $qmgr | grep -oP '(?<= STATUS\().*(?=\))')

        if [ "${status}" = "" ]; then
            writelog "無法獲得 listener $listener 狀態"
            # Do something
            continue
        elif [[ ${status} != "RUNNING" ]]; then
            writelog "Warning !! listener $listener 沒有 Running, 叫救護車"
            echo "START listener($listener)" | runmqsc $qmgr
        else
            DEBUG "listner $listener in $qmgr is $status "
        fi
    done

done
