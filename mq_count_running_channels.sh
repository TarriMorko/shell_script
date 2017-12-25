#!/bin/bash
#
#

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

QMGRS=$(dspmq | grep Running |  sed 's/).*//g' | sed 's/.*(//g')

for qmgr in $QMGRS; do
    DEBUG "qmgr: $qmgr"
    count_of_running_channels=$(echo "DISPLAY CHS(*)" |
        runmqsc $qmgr |
        grep RUNNING |
        wc -l)
    
    if [ $count_of_running_channels -gt 250 ]; then
        writelog "在這裡發簡訊"
    else
        DEBUG "Count of running channles: $count_of_running_channels"
    fi
done
