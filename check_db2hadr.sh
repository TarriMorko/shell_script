#!/bin/sh
#
# execute by instance owner

DETECT_TIME=30
WAIT_TIME_FOR_CONNECTION_TEST=30
LOGFILENAME="/home/db2inst1/check_db2hadr.log"

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
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}"  | tee -a ${LOGFILENAME}
}
typeset -fx writelog




echo "check_db2hadr.sh 的 pid 是 $$"


connect_test() {
  db2 connect to REMOTE_S user db2inst1 using 2iliaxZ 1>>$LOGFILENAME 2>&1
  db2 -x "select current timestamp from sysibm.sysdummy1" >timestamp.txt
  writelog "Get timestamp: " $(cat timestamp.txt)

  # 這段有可能因為連線異常而馬上終止，比方說 primary db 根本沒起、馬上返回一個無法連線
  # 2018-10-30 21:22:00 [chec] Get timestamp: SQL1024N 資料庫連接不存在。 SQLSTATE=08003
  #
  # 我需要處理這種狀況嗎？

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
    writelog "PEER la! sleep $DETECT_TIME sec."
    sleep $DETECT_TIME
    continue
  fi


  writelog "HADR_STAT is in $HADR_STATE, start a connection test..."
  connect_test &
  connect_test_PID=$!
  echo "connect_test 的 pid 是 $connect_test_PID" # DEBUG
  
  sleep $WAIT_TIME_FOR_CONNECTION_TEST
  ps -p $connect_test_PID # >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # connection hang
    writelog "Do Something. terminate"
    exit 1
    # do something 
  else
    # connection end immediately. include connection fail.
    writelog "Do nothing. sleep $DETECT_TIME sec."
    sleep $DETECT_TIME
    continue
  fi



done

