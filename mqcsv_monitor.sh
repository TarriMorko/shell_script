#!/bin/bash
# BASH Functions file
# Filename:		endqm.sh
# Tested on OS:	Linux, Fedora 6
# Author:		Steve Robinson
# Date Created:	February 2008
# Arguments:		Queue Manager Name
# Decription: 	This script ends a queue manager and pools the Queue Manager status until ended
# Version:		1.0
# History:-
# 10-February-2008 - version 1.0 - Created.
###################################################################################
##	Global Variables
###################################################################################
localHost=$(hostname)
_DEBUG="on"
MQUSER="mqm"
# QMGRS=$(su - $MQUSER -c "dspmq" | sed 's/).*//g' | sed 's/.*(//g')
QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g' )
###################################################################################
##	Debug Function
###################################################################################
##	Global Variables for sending SMS Alarm
ACCOUNT=AA34567
FILENAME_PRIFIX=${ACCOUNT}$(date +%Y%s)
TXT_FILE="${FILENAME_PRIFIX}.txt"
END_FILE="${FILENAME_PRIFIX}.end"
TXT_MODE="C"
PHONE_NUMBER="0900123456 0900345988"

## Variables and functions for logging
_DEBUG="on"
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

#####################################################################################
##	Main Routine
#####################################################################################

main() {

    # DEBUG "Status: Entering Main Routine.. "
    # DEBUG "Status: Checking to see if [$qmname] exists? ..."

    qm=$(dspmq | awk '{ print $1 }' | sed 's/QMNAME(//g;s/)//g' | grep -o $qmname)
    if [ "$qm" = "" ]; then
        DEBUG "Status: [$qmname] does not exist!"
        # $(crtmqm $qmname)
        DEBUG "Failure: Exiting with value 1"
    else
        # DEBUG "Status: [$qmname] exists"
        # status=$(dspmq -m $qmname | cut -d '(' -f2,3 | cut -d ')' -f2 | cut -d '(' -f2)
        status=$( dspmqcsv $qmname | grep -v ^$ | awk '{print $NF}' )

        DEBUG status of queue manager [$qmname] mqcsv is [$status]
        if [ "$status" = "Stopped" ]; then
            DEBUG "Status: Starting: [$qmname] mqcsv"

            writelog "發個簡訊"
            sleep 10
            
            strmqcsv $qmname
            status=$( dspmqcsv $qmname | grep -v ^$ | awk '{print $NF}' )

            while [ "$status" != "Running" ]; do
                sleep 5
                echo "Not Running..."
                strmqcsv $qmname
                status=$( dspmqcsv $qmname | grep -v ^$ | awk '{print $NF}' )
            done

            DEBUG status of queue manager [$qmname] mqcsv is [$status]
            DEBUG "Success: Exiting with value 0"
        fi
    fi
}

####################################################################################
##	Entry Point
####################################################################################
for qmname in $QMGRS; do
    main
done

exit 0
