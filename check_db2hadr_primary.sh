#!/bin/sh
#
#

db2 connect to sample  1>/dev/null 2>&1
connect_result=$?

db2 -x "select CURRENT TIMESTAMP from sysibm.sysdummy1" 1>/dev/null 2>&1
select_result=$?

if [ $connect_result -eq 0 -a $select_result -eq 0  ]; then
  date +%s > /tmp/current_timestamp.txt # some GPFS filesystem
fi

scp /tmp/current_timestamp.txt db2inst1@hadr02:/tmp/current_timestamp.txt # simulatation # DEBUG