#!/usr/bin/ksh
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= parameters set up =*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
INST=inst411
DBNM=tp1
KEEPDAYS=65
OUTPATH="/home/$INST/db2cmd/log/reorg/"

if [ -z "${OUTPATH}" ]; then
   echo "the OUTPUT path is not specified, sh terminate."
   exit
else
   find ${OUTPATH} -name "*Tablestatistics" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*aft" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*bef" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*out" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*schemas" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*tables" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*txt" -type f -ctime +${KEEPDAYS} -delete
   find ${OUTPATH} -name "*gz" -type f -ctime +${KEEPDAYS} -delete
fi

after_reorg_table_wait_time=1  # DEBUG 原本是 60
after_reorg_index_wait_time=1  # DEBUG 原本是 60

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= other initialize *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
. /home/$INST/sqllib/db2profile

set -x
export LANG=c
# TODAY='date +%b%d'   # DEBUG  # AIX 上要改回來這兩行
# alias today=$TODAY   # DEBUG  # AIX 上要改回來這兩行
TODAY='date +%b%d'   # DEBUG
alias today='date +%b%d'  # DEBUG
outfile=$OUTPATH/reorg.$DBNM.`today`.out

RC_connect=0
RC_reorgtb=0
RC_reorgix=0
RC_runstat=0

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= status chk before*=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
mkdir -p $OUTPATH
chmod 775 $OUTPATH
db2pd -d $DBNM -reorg > $OUTPATH/db2pd-reorg.$DBNM.`today`.bef
db2pd -d $DBNM -runstat > $OUTPATH/db2pd-runstat.$DBNM.`today`.bef

echo ==== START Process $DBNM >> $outfile
date >> $outfile

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= make connection  *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
db2 -v connect to $DBNM  >> $outfile
rc=$?
if  [[ $rc -ne 0 ]]; then
   RC_connect=$rc
   return $RC_connect
   exit
fi

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= get tables info  *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
# get schema names
#db2 -x "list tables for all" | awk '{print $2}' | sort -u | grep -E -v "SYSCAT|SYSIBMADM|SYSPUBLIC|SYSSTAT|SYSIBM|SYSTOOLS" > $OUTPATH/$DBNM.schemas
db2 -x "select schemaname from syscat.schemata" | grep -E -v "SYSCAT|SYSIBMADM|SYSPUBLIC|SYSSTAT|SYSIBM|SYSTOOLS|NULLID|SQLJ|SYSFUN|SYSIBMINTERNAL|SYSIBMTS|SYSPROC" > $OUTPATH/$DBNM.schemas

# get table names by schema
for SCHNM in `cat $OUTPATH/$DBNM.schemas|awk '{print $1}' `
do
   #db2 -x "list tables for schema $SCHNM"  | grep -v " V " | grep -v " A " > $OUTPATH/$DBNM.$SCHNM.tables
   db2 -x "select tabname from syscat.tables where tabschema='$SCHNM' and type='T'" > $OUTPATH/$DBNM.$SCHNM.tables

   #echo "select tabname from syscat.tables where tabschema='${SCHNM}' and type='T';" > $OUTPATH/$DBNM.$SCHNM.tables.sel_sql
   #db2 -xtvf $OUTPATH/$DBNM.$SCHNM.tables.sel_sql > $OUTPATH/$DBNM.$SCHNM.tables
done


#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*=    reorg chk     *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
# reorgchk and overwrite  $OUTPATH/$DBNM.$SCHNM.tables


db2 reorgchk current statistics on table all > $OUTPATH/$DBNM.reorgchk.tables.`today`.out
awk 'BEGIN{a=0}/Index statistics/{a=NR}{if(a<=0)print $0}' $OUTPATH/$DBNM.reorgchk.tables.`today`.out > $OUTPATH/$DBNM.reorgchk.Tablestatistics.`today`.out
awk '{ X[NR]=$0 } /\*/{print X[(NR-1)]} ' $OUTPATH/$DBNM.reorgchk.Tablestatistics.`today`.out | grep "Table:" | awk '{print $NF}' | grep -E -v "SYSCAT|SYSIBMADM|SYSPUBLIC|SYSSTAT|SYSIBM|SYSTOOLS|NULLID|SQLJ|SYSFUN|SYSIBMINTERNAL|SYSIBMTS|SYSPROC" >$OUTPATH/${DBNM}_table_need_reorg_$(today).txt


awk 'BEGIN{a=0}/Index statistics/{a=NR}{if(a>0)print $0}' $OUTPATH/$DBNM.reorgchk.tables.`today`.out  > $OUTPATH/$DBNM.reorgchk.Indexstatistics.`today`.out
awk '/Table:/{a=$2} /\*/{print a} ' $OUTPATH/$DBNM.reorgchk.Indexstatistics.`today`.out | grep -v ^$ | uniq  | grep -E -v "SYSCAT|SYSIBMADM|SYSPUBLIC|SYSSTAT|SYSIBM|SYSTOOLS|NULLID|SQLJ|SYSFUN|SYSIBMINTERNAL|SYSIBMTS|SYSPROC" >$OUTPATH/${DBNM}_index_need_reorg_$(today).txt
exit #DEBUG


#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*=   reorg tables   *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#


for target_table in `cat $OUTPATH/${DBNM}_table_need_reorg_$(today).txt`; do
   date >> $outfile
   db2 -v "select count(*) from $target_table" >> $outfile
   date >> $outfile
   db2 -v reorg table $target_table inplace allow write access >> $outfile
   rc=$?
   if  [[ $rc -ne 0 ]]; then
      RC_reorgtb=$rc
   fi
   date >> $outfile
done

echo " ===> Online REORG Tables submitted with RC="$RC_reorgtb >>  $outfile
sleep $after_reorg_table_wait_time

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*=   reorg indexes  *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#

for target_table_for_index in `cat $OUTPATH/${DBNM}_index_need_reorg_$(today).txt `
do
   date >> $outfile
   db2 -v reorg indexes all for table $target_table_for_index allow write access >> $outfile
   rc=$?
   if  [[ $rc -ne 0 ]]; then
      RC_reorgix=$rc
   fi
   date >> $outfile
done


echo " ===> Online REORG Indexes finished with RC="$RC_reorgix >>  $outfile
sleep $after_reorg_index_wait_time

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= after reorg runstat  *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
for SCHNM in `cat $OUTPATH/$DBNM.schemas|awk '{print $1}' `
do
   for tv in `cat $OUTPATH/$DBNM.$SCHNM.tables|awk '{print $1}' `
   do
      date >> $outfile
      db2 -v runstats on table $SCHNM.$tv  with distribution on all columns and detailed indexes all >> $outfile
      rc=$?
      if  [[ $rc -ne 0 ]]; then
         RC_runstat=$rc
      fi
      date >> $outfile
   done
done

echo "Runstats finished with RC="$RC_runstat >>  $outfile

db2 -v terminate  >> $outfile
date >> $outfile

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= status chk after *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
db2pd -d $DBNM -reorg > $OUTPATH/db2pd-reorg.$DBNM.`today`.aft
db2pd -d $DBNM -runstat > $OUTPATH/db2pd-runstat.$DBNM.`today`.aft

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= log housekeeping *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
find $OUTPATH -mtime +$KEEPDAYS -exec rm {} \;

#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
#=*=*= return RC to caller (if any) *=*=*=#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
if  [[ $RC_reorgtb -ne 0 ]]; then
   return $RC_reorgtb
   exit
fi
if  [[ $RC_reorgix -ne 0 ]]; then
   return $RC_reorgix
   exit
fi
if  [[ $RC_runstat -ne 0 ]]; then
   return $RC_runstat
   exit
fi

