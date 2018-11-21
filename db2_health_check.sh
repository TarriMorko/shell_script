#!/bin/sh
#
#
# execute by instance owner
# * 11,15 * * * su - <instance>  -c "/home/<instance>/db2_health_check.sh >/dev/null 2>&1"

CUSTOMER="CUB"
BUSINESS="ELOAN"
INSTANCE=$USER
MONTH=$(date +%m)

WORKING_DIR=/tmp/IBM_IMA
OUTPUT_DIR=/tmp/IBM_IMA/IMA_data

export LC_ALL=POSIX
export LANG=POSIX

cd $WORKING_DIR

databases=$(db2 list db directory | awk '/Database alias/{a=$NF} /Directory entry type                 = Indirect/{print a}' | sed 's/ //g')

for db in $databases; do
  db2 connect to $db >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    db2 -txf ${WORKING_DIR}/db2_health_check.sql | tr -s ' ' >>${OUTPUT_DIR}/HealthCheck_${CUSTOMER}_${BUSINESS}_${INSTANCE}_${db}_${MONTH}.txt
    db2 terminate
  else
    echo $(date +"%Y-%m-%d %H:%M:%S") "Can not connect to $db" >>${OUTPUT_DIR}/HealthCheck_${CUSTOMER}_${BUSINESS}_${INSTANCE}_${db}_${MONTH}.txt
  fi
done
