#!/bin/sh
#
#
# execute by instance owner
# * 6 1 * * su - <instance>  -c "/home/<instance>/db2_health_get_diaglog.sh >/dev/null 2>&1"

OUTPUT_DIR=/tmp/IBM_IMA
DIAGPATH=<location of db2diaglog>

# remove old diaglog in OUTPUT_DIR
find $OUTPUT_DIR -name "*db2diag*" -mtime +35 -exec rm {} \;

find $DIAGPATH -name "*db2diag*" -mtime -30 -exec cp {} ${OUTPUT_DIR} \;