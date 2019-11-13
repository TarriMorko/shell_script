#!/bin/sh
#
# show_63148port_STATUS_counts.sh
################################################################################

export LANG=C
_netstat="$RANDOM"_tmp_netstat

netstat -Aan | grep .63148 > _netstat  # DEBUG 

LISTEN=$(cat _netstat | grep LISTEN | wc -l )
SYN_RECV=$(cat _netstat | grep SYN_RECV | wc -l )
ESTABLISHED=$(cat _netstat | grep ESTABLISHED | wc -l )
CLOSE_WAIT=$(cat _netstat | grep CLOSE_WAIT | wc -l )
LAST_ACK=$(cat _netstat | grep LAST_ACK | wc -l )
CLOSED=$(cat _netstat | grep CLOSED | wc -l )

printf "$(date +"%Y-%m-%d %H:%M:%S") LISTEN %-4s SYN_RECV %-4s ESTABLISHED %-4s CLOSE_WAIT %-4s LAST_ACK %-4s CLOSED %-4s\n" $LISTEN $SYN_RECV $ESTABLISHED $CLOSE_WAIT $LAST_ACK $CLOSED

rm _netstat
