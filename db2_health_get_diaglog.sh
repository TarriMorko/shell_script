#!/bin/sh
#
#
# execute by instance owner
# * 6 1 * * su - <instance> -c "/tmp/IBM_IMA/db2_health_get_diaglog.sh >/dev/null 2>&1"
#

DIAGPATH=/home/inst411/sqllib/db2dump
WORKING_DIR=/tmp/IBM_IMA
OUTPUT_DIR=/tmp/IBM_IMA/IMA_data
OUTPUT_FILE=${WORKING_DIR}/IBM_IMA_$(date +%Y%m%d).tar 

export LC_ALL=POSIX
export LANG=POSIX

mkdir -p ${OUTPUT_DIR} >/dev/null 2>&1

find ${OUTPUT_DIR}  -mtime +40 -exec rm {} \;
# remove old diaglog in OUTPUT_DIR

find $DIAGPATH -name "*db2diag*" -mtime -35 -exec cp {} ${OUTPUT_DIR} \;
# copy diaglog to OUTPUT_DIR

databases=$(db2 list db directory | awk '/Database alias/{a=$NF} /Directory entry type                 = Indirect/{print a}' | sed 's/ //g')
for db in $databases; do
  db2support -d $db -s -m -c -timeout 15 -H 30d -o ${OUTPUT_DIR}/db2support_$db.zip
done

tar -cvf ${OUTPUT_FILE} /tmp/IBM_IMA/IMA_data
gzip -f ${OUTPUT_FILE}


