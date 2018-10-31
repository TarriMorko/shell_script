#!/bin/sh
#
# execute by instance owner

START_TIME=5
DETECT_TIME=30
WAIT_TIME_FOR_CONNECTION_TEST=30
LOGFILENAME="/home/db2inst1/check_db2hadr.log"
GPFSFILE="/tmp/current_time.txt"


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
  #    writelog "Hello World!"
  # then a message "2014-11-22 15:38:54 [who_call] Hello World!"
  # writing in file LOGFILENAME.
  #######################################
  #_caller=$(echo $0 | cut -d'/' -f2)
  _caller=$(echo ${0##*/} | awk '{print substr($0,1,16)}')
  log_message=$@
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}
typeset -fx writelog

writelog "Wait $START_TIME sec."
sleep $START_TIME

connect_test() {
  CONNECTIONRESULT=""
  db2 connect to REMOTE_S user db2inst1 using 2iliaxZ 1>>$LOGFILENAME 2>&1
  if [[ $? -eq 0 ]]; then
    CONNECTIONRESULT="True"
  else
    CONNECTIONRESULT="False"
  fi
  db2 -x "select current timestamp from sysibm.sysdummy1" >timestamp.txt
  writelog "Get timestamp: " $(cat timestamp.txt)

  sleep 100 # simulate hang # DEBUG
}

while [ true ]; do

  HADR_ROLE=$(db2pd -d sample -hadr | grep HADR_ROLE | awk -F'=' '{print $NF}' | sed 's/ //g')

  if [ "${HADR_ROLE}" == "STANDBY" ]; then
    :
  else
    writelog "This script should run on DB2 HADR STANDBY. sleep $DETECT_TIME sec."
    sleep $DETECT_TIME
    continue
  fi

  HADR_STATE=$(db2pd -d sample -hadr | grep HADR_STATE | awk -F'=' '{print $NF}' | sed 's/ //g')

  if [ "${HADR_STATE}" == "PEER" ]; then
    writelog "HADR state PEER"
    sleep $DETECT_TIME
    continue
  fi

  writelog "HADR state $HADR_STATE, start a connection test..."
  connect_test &
  connect_test_PID=$!
  writelog "wait $WAIT_TIME_FOR_CONNECTION_TEST sec."
  sleep $WAIT_TIME_FOR_CONNECTION_TEST
  ps -p $connect_test_PID >/dev/null 2>&1

  if [ $? -eq 0 -o "${CONNECTIONRESULT}" == "False" ]; then
    # connection hang
    writelog "Connection hang or fail."
  else
    writelog "Do nothing. sleep $DETECT_TIME sec."
    sleep $DETECT_TIME
    continue
  fi

  writelog "check GPFS file."
  standby_time=$(date +%H:%M)
  primary_time=$(awk -F':' '{print $1 ":" $2}' $GPFSFILE)
  writelog "standby_time: $standby_time" # DEBUG
  writelog "primary_time: $primary_time" # DEBUG
  if ! [ "${standby_time}" == "${primary_time}" ]; then
    writelog "要叫救護車了"
    # do something  
    exit 1
  else
    writelog "sleep $DETECT_TIME sec."
    sleep $DETECT_TIME
  fi

done
