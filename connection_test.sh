#!/bin/sh
#
#

LOGFILENAME="/tmp/mw_hc2.log"

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
  # then a message "2014-11-22 15:38:54 [who_call] Hello World!"
  # writing in file LOGFILENAME.
  #######################################
  #_caller=$(echo $0 | cut -d'/' -f2)
  _caller=$(echo ${0##*/} | awk '{print substr($0,1,4)}')
  log_message=$@
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}"  | tee -a ${LOGFILENAME}
}
typeset -fx writelog



echo $$ # DEBUG
HADR_ROLE=$(db2pd -d sample -hadr | grep HADR_ROLE | awk -F'=' '{print $NF}' | sed 's/ //g')

if ! [ "${HADR_ROLE}" == "STANDBY" ]; then
  echo "This script should run on DB2 HADR STANDBY "
  exit 1
fi

HADR_STATE=$(db2pd -d sample -hadr | grep HADR_STATE | awk -F'=' '{print $NF}' | sed 's/ //g')

if [ "${HADR_ROLE}" == "PEER" ]; then
  echo "PEER la!"

else
  db2 connect to REMOTE_S user db2inst1 using 2iliaxZ 1>/dev/null 2>&1
  db2 -x "select current timestamp from sysibm.sysdummy1" >>timestamp.txt

  sleep 10 # simulate hang # DEBUG
fi
