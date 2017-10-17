#!/bin/bash
#
#

_DEBUG="off"
DEBUG() {
    [ "$_DEBUG" == "on" ] && echo "$(date +"%Y-%m-%d %H:%M:%S") $@" || :
}

writelog() {
    log_message=$@
    echo "$(date +"%Y-%m-%d %H:%M:%S") ${log_message}" # | tee -a ${LOGFILENAME}
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
            writelog "Warning !! 無法獲得 listener $listener 狀態"
            # Do something
            continue
        else
            writelog "Status of listner $listener in $qmgr is $status "
        fi

        if [[ ${status} != "RUNNING" ]]; then
            writelog "Warning !! listener $listener 沒有 Running, 叫救護車"
        fi
    done

done
