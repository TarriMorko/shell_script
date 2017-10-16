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
QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g')
###################################################################################
##	Debug Function
###################################################################################
DEBUG() {
    [ "$_DEBUG" == "on" ] && $@ || :
}

#####################################################################################
##	Main Routine
#####################################################################################

main() {

    DEBUG echo "Status: Entering Main Routine.. "
    DEBUG echo "Status: Checking to see if [$qmname] exists? ..."

    qm=$(dspmq | awk '{ print $1 }' | sed 's/QMNAME(//g;s/)//g' | grep -o $qmname)
    if [ "$qm" = "" ]; then
        DEBUG echo "Status: [$qmname] does not exist!"
        # $(crtmqm $qmname)
        DEBUG echo "Failure: Exiting with value 1"
    else
        DEBUG echo "Status: [$qmname] exists"
        status=$(dspmq -m $qmname | cut -d '(' -f2,3 | cut -d ')' -f2 | cut -d '(' -f2)
        DEBUG echo status of queue manager [$qmname] is [$status]
        if [ "$status" = "Ended unexpectedly" ]; then
            DEBUG echo "Status: Starting: [$qmname]"

            echo "發個簡訊"
            
            strmqm $qmname

            

            while [ "$status" != "Running" ]; do
                sleep 5
                echo "Running..."
                status=$(dspmq -m $qmname | cut -d '(' -f2,3 | cut -d ')' -f2 | cut -d '(' -f2)
            done
            DEBUG echo status of queue manager [$qmname] is [$status]
            DEBUG echo "Success: Exiting with value 0"
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
