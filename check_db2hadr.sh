#!/bin/sh
#
# execute by instance owner

START_TIME=10
DETECT_TIME=60
WAIT_TIME_FOR_CONNECTION_TEST=60
LOGFILENAME="/home/db2inst1/check_db2hadr.log"
GPFSFILE="/tmp/current_timestamp.txt"
GPFS_TIMEOUT=60

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
  _caller=$(echo ${0##*/} | awk '{print substr($0,1,16)}')
  log_message=$@
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}
typeset -fx writelog

connect_test() {
  #######################################
  # Create a connection test to primary database.
  #######################################  
  touch CONNECTIONRESULT
  db2 connect to REMOTE_S user db2inst1 using 2iliaxZ 1>>$LOGFILENAME 2>&1
  if [[ $? -eq 0 ]]; then
    echo "True" >CONNECTIONRESULT
  else
    echo "False" >CONNECTIONRESULT
  fi
  db2 -x "select current timestamp from sysibm.sysdummy1" >timestamp.txt
  writelog "Get timestamp: " $(cat timestamp.txt)

  # sleep 10 # simulate hang # DEBUG
}

is_hadr_role_standby() {
  #######################################
  # Check db2 hadr role
  # Returns:
  #    0 : db2 hadr role is STANDBY
  #    1 : db2 hadr role is NOT STANDBY
  #######################################  
  HADR_ROLE=$(db2pd -d sample -hadr | grep HADR_ROLE | awk -F'=' '{print $NF}' | sed 's/ //g')

  if [ "${HADR_ROLE}" == "STANDBY" ]; then
    return 0
  elif [ "${HADR_ROLE}" == "" ]; then
    writelog "Can not get HADR_ROLE."
    writelog "TERMINATE."
    return 1
  else
    writelog "HADR ROLE is ${HADR_ROLE}."
    writelog "This script should run on DB2 HADR STANDBY. "
    writelog "TERMINATE."
    return 1
  fi
}

is_hadr_state_peer() {
  #######################################
  # Check db2 hadr state
  # Returns:
  #    0 : db2 hadr state is PEER
  #    1 : db2 hadr state is NOT PEER
  #######################################   
  HADR_STATE=$(db2pd -d sample -hadr | grep HADR_STATE | awk -F'=' '{print $NF}' | sed 's/ //g')
  writelog "HADR state $HADR_STATE"

  if [ "${HADR_STATE}" == "PEER" ]; then
    return 0
  else
    return 1
  fi
}

is_primary_db_able_to_connect() {
  #######################################
  # Connect to primary db
  # Returns:
  #    0 : Able_to_connect primary db
  #    1 : Unable_to_connect primary db or timeout
  #######################################   
  writelog "HADR state $HADR_STATE, start a connection test..."
  connect_test &
  connect_test_PID=$!
  writelog "wait $WAIT_TIME_FOR_CONNECTION_TEST sec."
  sleep $WAIT_TIME_FOR_CONNECTION_TEST
  ps -p $connect_test_PID # >/dev/null 2>&1
  rc=$?
  if [ $rc -eq 0 -o "$(cat CONNECTIONRESULT)" == "False" ]; then
    # connection hang
    writelog "Connection to primary db hang or fail."
    return 1
  else
    writelog "Able_to_connect primary db. sleep $DETECT_TIME sec."
    return 0
  fi
}

is_GPFS_can_read() {
  #######################################
  # Open a file in GPFS, check its content.
  #
  # Returns:
  #    0 : The tolerance for timestamp in second less than $GPFS_TIMEOUT
  #    1 : The tolerance for timestamp in second greater eq than $GPFS_TIMEOUT
  #######################################     
  writelog "check GPFS file."

  standby_time=$(date +%s)
  primary_time=$(cat $GPFSFILE)

  writelog "standby_time: $standby_time" # DEBUG
  writelog "primary_time: $primary_time" # DEBUG

  timestamp_diff=$(echo $standby_time - $primary_time | bc)

  if [ $timestamp_diff -ge $GPFS_TIMEOUT ]; then
    writelog "誤差 $timestamp_diff 秒"
    writelog "要叫救護車了"
    # do something  
    return 1
  else
    writelog "誤差 $timestamp_diff 秒，在允許範圍內。"
    return 0
  fi

}

writelog "Wait $START_TIME sec for first check."
sleep $START_TIME
writelog "======= First connection test ========== "
is_hadr_role_standby || exit 1
is_hadr_state_peer || exit 1
is_primary_db_able_to_connect || exit 1
is_GPFS_can_read || exit 1
writelog "======= First connection test done.====="

while [ true ]; do

  sleep $DETECT_TIME

  is_hadr_role_standby || exit # 不是 standby 就退出

  is_hadr_state_peer && continue # peer 就繼續 loop,  不是 peer 需要往下檢查

  is_primary_db_able_to_connect && continue # 可連線到 primary 就繼續 loop，不能連就往下檢查

  is_GPFS_can_read && continue # 可讀取到 GPFS 檔案且時間誤差在 $GPFS_TIMEOUT 秒之內就繼續 loop, 不能就往下

  writelog "Shutdown primary..."

  # initiate_LPAR_dump.sh 

  f writelog "Shutdown primary done."

  exit 1

done
