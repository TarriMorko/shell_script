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
QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g')
###################################################################################
##	Debug Function
###################################################################################
DEBUG() {
    [ "$_DEBUG" == "on" ] && echo "$(date +"%Y-%m-%d %H:%M:%S") $@" || :
}

writelog() {
    log_message=$@
    echo "$(date +"%Y-%m-%d %H:%M:%S") ${log_message}" # | tee -a ${LOGFILENAME}
}
#####################################################################################
##	Main Routine
#####################################################################################

main() {

    DEBUG "Entering Main Routine.. "
    DEBUG "Checking to see if [$qmgr] exists? ..."

    qm=$(dspmq | awk '{ print $1 }' | sed 's/QMNAME(//g;s/)//g' | grep -o $qmgr)

    if [ "$qm" = "" ]; then
        DEBUG "[$qmgr] does not exist!"
        # $(crtmqm $qmgr)
        DEBUG "Failure: Exiting with value 1"
    else
        DEBUG "[$qmgr] exists"
        status=$(dspmq -m $qmgr | cut -d '(' -f2,3 | cut -d ')' -f2 | cut -d '(' -f2)
        DEBUG status of queue manager [$qmgr] is [$status]
        if [ "$status" = "Ended unexpectedly" ]; then
            DEBUG "Starting: [$qmgr]"
            strmqm $qmgr

            writelog "這裡有問題ㄟ，發個簡訊"

            while [ "$status" != "Running" ]; do
                sleep 5
                echo "Running..."
                status=$(dspmq -m $qmgr | cut -d '(' -f2,3 | cut -d ')' -f2 | cut -d '(' -f2)
            done
            DEBUG status of queue manager [$qmgr] is [$status]
            DEBUG "Success: Exiting with value 0"
        fi
    fi
}

####################################################################################
##	Entry Point
####################################################################################
for qmgr in $QMGRS; do
    main
done

exit 0
