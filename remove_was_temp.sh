#!/bin/sh
#
#

AUDIT_LOG=/src/mwadmin/mwadmin_audit.log
LOGFILENAME=$AUDIT_LOG
ALLOWED_USER="root"
HOST=$(hostname)
LOGIN=$(whoami)

profile_root="/opt/IBM/WebSphere/AppServer/profiles/Dmgr01"

writelog() {
  _caller=$(echo ${0##*/} | awk '{print substr($0,1,4)}')
  log_message=$@
  echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}
typeset -fx writelog

if ! [ -d "${profile_root}" ]; then
  writelog "$profile_root dones not exist."
  exit 1
fi

if [ "${LOGIN}" != "${ALLOWED_USER}" ]; then
  writelog "User ID check failed. Abort."
  exit 1
else
  writelog "User ID check successful. Continue."
fi

ps -ef | grep wasadmin \
        | grep java \
        | grep -v getPMI \
        | grep -v wily \
        | grep -v grep \
        | grep $profile_root >/dev/null

if [ $? -eq 0 ]; then
  writelog "Stop all WebSphere Application Server-related Java processes before deleting WSTEMP files."
  exit 1
fi

# MUST add * at the end of LINE !!!
# DO NOT REMOVE WAS_TEMP directory itself !!!
WAS_TEMP_DIRS="
${profile_root}/temp/*
${profile_root}/wstemp/*
${profile_root}/config/temp/*
"

for WAS_TEMP_DIR in $WAS_TEMP_DIRS; do
  writelog removing "${WAS_TEMP_DIR}"
  rm -rf "${WAS_TEMP_DIR}"
done
