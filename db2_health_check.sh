#!/bin/sh
#
#

db2 connect to tp1 >/dev/null 2>&1
while true
do
db2 -txf db2_health_check.sql
sleep 3
done