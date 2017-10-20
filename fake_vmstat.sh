#!/bin/bash
#
#

awk '{print $0; system( "sleep 1")}' 20171019_vmstat.log
