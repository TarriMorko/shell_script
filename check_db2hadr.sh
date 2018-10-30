#!/bin/sh
#
# execute by instance owner

./connection_test.sh &

connection_test_PID=$!
sleep 30 # timeout for db connection response

ps -p $connection_test_PID >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # connection hang
  # do something 
  printf "%s%s" "$(date)" "Do Something."
else
  # connection end as normal
  printf "%s%s" "$(date)" "Do nothing."
fi
