#!/bin/ksh

ssh hscroot@ssc4 chsysstate -r lpar -m TSC1 -n ssc3_NIM -o dumprestart
count=0
while [[ $count < 3 ]]
do
  sleep 5
  OUTPUT=`ssh hscroot@ssc4 lsrefcode -r lpar -m TSC1 --filter lpar_names=ssc3_NIM | perl -ne 'print $1 if /refcode=([^,]*)/'`
  if echo $OUTPUT | grep -qE '^00c'
  then
    exit
  fi
  count=$((count + 1))
done
ssh hscroot@ssc4 chsysstate -r lpar -m TSC1 -n ssc3_NIM -o shutdown --immed