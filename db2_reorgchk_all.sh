#!/usr/bin/ksh
#
#

if [ $# -eq 0 ]; then
  echo "Please input INSTANCE name."
  echo "ex: ./db2_reorgchk_all.sh db2inst1"
  echo
  exit
else
  export LANG=en_US
  INSTNAME=$1
fi

db2level >/dev/null
rc=$?
if [ $rc -ne 0 ]; then
  echo "Can not source db2profile. Exit."
  exit
fi

DATABASES=$(
  db2 list db directory | awk '/alias/{a=$NF}/Indirec/{print a}' | sed 's/ //g'
)

for database in ${DATABASES}; do
  db2 connect to $database >/dev/null 2>&1
  db2 reorgchk current statistics on table all >${database}_reorgchk.out
  cat ${database}_reorgchk.out | grep '*' -B 1 | grep "Index:" | awk '{print $NF}' >>${database}_index_need_reorg.txt
  cat ${database}_reorgchk.out | grep '*' -B 1 | grep "Table:" | awk '{print $NF}' >>${database}_table_need_reorg.txt
  db2 terminate >/dev/null 2>&1
  rm ${database}_reorgchk.out
done
