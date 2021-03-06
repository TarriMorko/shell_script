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


QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g' )

for qmgr in $QMGRS
do

    localqueues=$(echo "dis ql(*)" |runmqsc $qmgr | grep -v SYSTEM | grep -o "QUEUE(.*)" | awk '{print $1}' | cut -d'(' -f2 | cut -d')' -f1)

    for localqueue in $localqueues
    do

        queue_depth_count=$(echo "dis ql($localqueue) curdepth" | runmqsc $qmgr| grep CUR | cut -d'(' -f2  | cut -d')' -f1)

        DEBUG "Warning : The current depth of local queue $localqueue in $qmgr is $queue_depth_count!!"

        if [ $queue_depth_count -gt 0 ]; then
            writelog "簡訊測試"
            sleep 1
        fi
    done
done
