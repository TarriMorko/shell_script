#!/bin/bash
#
#

## Variables and functions for logging
_DEBUG="on"
LOGFILENAME="mq_bot_curdepth.log"

DEBUG() {
  [ "$_DEBUG" == "on" ] && echo "$(date +"%Y-%m-%d %H:%M:%S") $@" || :
}

writelog() {
  #######################################
  # Writing log to specify file
  # Globals:
  #    LOGFILENAME
  # Arguments:
  #    _caller
  #    log_message
  # Returns:
  #    None
  # Example:
  #    write_log "Hello World!"
  #
  #   then a message "2014-11-22 15:38:54 [who_call] Hello World!"
  #   writing in file LOGFILENAME.
  #######################################
  #_caller=$(echo $0 | cut -d'/' -f2)
  _caller=$(echo ${0##*/} | awk '{print substr($0,1,4)}')
  log_message=$@
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}
typeset -fx writelog

QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g')

DEBUG QMGRS: $QMGRS

for qmgr in $QMGRS; do

  localqueues=$(echo "dis ql(*)" | runmqsc $qmgr | grep -v SYSTEM | grep -o "QUEUE(.*)" | awk '{print $1}' | cut -d'(' -f2 | cut -d')' -f1)

  DEBUG QMGR:${qmgr}, queue:${localqueues}

  for localqueue in $localqueues; do

    queue_depth_count=$(echo "dis ql($localqueue) curdepth" | runmqsc $qmgr | grep CUR | cut -d'(' -f2 | cut -d')' -f1)

    DEBUG "The current depth of local queue $localqueue in $qmgr is $queue_depth_count!!"

    if [ $queue_depth_count -gt 1 ]; then
      writelog "Warning : The current depth of local queue $localqueue in $qmgr is $queue_depth_count!!"
      sleep 1
    fi
  done
done
