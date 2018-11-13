#!/bin/sh
#
#
# 用 instance owner 跑

# 先找出所有 db
# 連接之後跑一次 db2_health_check.sql 輸出到 特定名稱
# CUB_eloan_$ins_$db_$month.txt

CUSTOMER="CUB"
BUSINESS="ELOAN"
INSTANCE=$USER
MONTH=$(date +%m)
OUTPUT_DIR=/tmp



export LC_ALL=POSIX
export LANG=POSIX


databases=$(db2 list db directory | awk '/Database alias/{a=$NF} /Directory entry type/{if($NF="Indirect"){b=a}} END{print b}' | sed 's/ //g')




for db in $databases ; do
  db2 connect to $db >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    db2 -txf db2_health_check.sql | tr -s ' ' >> ${OUTPUT_DIR}/HealthCheck_${CUSTOMER}_${BUSINESS}_${INSTANCE}_$db_${MONTH}.txt
    db2 terminate
  else
    echo $(date +"%Y-%m-%d %H:%M:%S") "Can not connect to $db" >> ${OUTPUT_DIR}/HealthCheck_${CUSTOMER}_${BUSINESS}_${INSTANCE}_$db_${MONTH}.txt
  fi
done

