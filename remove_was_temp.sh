#!/bin/sh
#
#

AUDIT_LOG=/src/mwadmin/mwadmin_audit.log
LOGFILENAME=$AUDIT_LOG
ALLOWED_USER="root"
HOST=$(hostname)
LOGIN=$(whoami)

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
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}
typeset -fx writelog

if [ "${LOGIN}" != "${ALLOWED_USER}" ]; then
  writelog "User ID check failed. Abort."
  exit 1
else
  writelog "User ID check successful. Continue."
fi

ps -ef | grep wasadmin | grep java | grep -v getPMI | grep -v wily | grep -v grep >/dev/null
if [ $? -eq 0 ]; then
  writelog "Stop all WebSphere Application Server-related Java processes before deleting WSTEMP files."
  exit 1
fi

# MUST add * at the end of LINE !!!
# DO NOT REMOTE WAS_TEMP directory itself !!!
WAS_TEMP_DIRS="
/tmp/1/*
/tmp/2/*
/tmp/3/*
"

for WAS_TEMP_DIR in $WAS_TEMP_DIRS; do
  writelog removing "${WAS_TEMP_DIR}"
  rm -rf "${WAS_TEMP_DIR}"
done
