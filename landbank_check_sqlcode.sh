#!/bin/sh
#
#

LOGFILENAME="tmp" # taipei  db2inst1.ABDBDAYT.ASN.QAPP.log debug
INTERVAL="10"     # detect interval in second

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
  _caller=$(echo ${0##*/} | awk '{print substr($0,1,24)}')
  log_message=$@
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}

monitor_sqlcode() {
  # Return 0 until get $1

  writelog "Checking sqlcode..."
  tail -n1 -f ${LOGFILENAME} | grep --line-buffered -q "The SQLCODE is \"$1\""
  # tail -1 -f ${LOGFILENAME} | grep -u -q "The SQLCODE is \"$1\""   # AIX debug
  return $?
}

server_status() {
  # ps -ef | grep -v grep | grep -q asnqapp # Debug
  ps -ef | grep -v grep | grep -q db2sysc # Debug

  return $?
}

while true; do
  monitor_sqlcode -30108

  if server_status; then
    writelog "$0 Found SQLcode. Restart server... "
    # run restart_apply_cha.ksh here
  else
    echo 'Server stopped.'
  fi

  echo "sleep $INTERVAL 秒" #DEBUG
  sleep $INTERVAL
done
