#!/bin/sh
#
#
# ahc_db2.sh
################################################################################

instance_list=$1

if [ $# -lt 2 ]; then
  echo "請輸入 instance 與 db 名稱、output directory 作為參數"
  echo "ex: ./ahc_db2.sh db2inst1 sample /home/db2inst1/ahc"
  echo
  exit
else
  export LANG=en_US
  instance=$1
  database=$2
  WORKDIR=$3

  # WORKDIR=/home/db2adm1/db1tabbk
  mkdir ${WORKDIR}/db2
  chmod 777 -R ${WORKDIR}
  Outfiles="db2.$(hostname)_${instance}_${database}_$(date +%Y%m%d_%S).tar"
fi



# find ${WORKDIR} -name "*gz" -type f -ctime +65 -delete


INSDIR=db2/ahc_$(hostname)_db2_${instance}
mkdir ${WORKDIR}/${INSDIR}
chmod 777 ${WORKDIR}/${INSDIR}
cd ${WORKDIR}/${INSDIR}

echo "Parsing ${instance} now"


db2pd -everything > $(hostname)_${instance}_db2pd_full.out
db2ilist > $(hostname)_db2_instance_list.out


echo "Parsing ${instance}'s ${database} now"

db2 list history backup all for ${database} > $(hostname)_${instance}_${database}_backup_status.out

TMP_TAB=${WORKDIR}/db2.${instance}.${database}.tab.sql

# To Get db2_instance_dbname_tbs_status into host_instance_dbname_tbs_status.out
echo "connect to ${database};
SELECT substr(CURRENT SERVER,1,9) AS DB_name,
substr(X.TBSP_ID,1,3) AS ID,
substr(X.TBSP_NAME,1,18) AS TBSP_NAME,
substr(X.TBSP_TYPE,1,4) AS TYPE,
substr(X.TBSP_STATE,1,1) AS S ,
substr(X.TBSP_TOTAL_SIZE_KB,1,14) AS Total_size_KB,
substr(X.TBSP_USED_SIZE_KB,1,13) AS Used_size_KB,
substr(X.TBSP_UTILIZATION_PERCENT,1,5) AS Usage from SYSIBMADM.TBSP_UTILIZATION X,sysibm.sysdummy1 D;
" > $TMP_TAB
chmod 777 $TMP_TAB

echo "DB_NAME   ID  TBSP_NAME          TYPE S TOTAL_SIZE_KB  USED_SIZE_KB   USAGE" > $(hostname)_${instance}_${database}_tbs_status.out
echo "--------- --- ------------------ ---- - -------------- ------------- ------" >> $(hostname)_${instance}_${database}_tbs_status.out
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_tbs_status.out
echo $? # TODO (0 or 4)

# To Get tables size, fetch first 120 rows only
echo "connect to ${database};
SELECT SUBSTR(TABSCHEMA,1,20) TABSCHEMA,SUBSTR(TABNAME,1,24) TABNAME,(DATA_OBJECT_P_SIZE + INDEX_OBJECT_P_SIZE + LONG_OBJECT_P_SIZE + LOB_OBJECT_P_SIZE + XML_OBJECT_P_SIZE) AS TOTAL_SIZE_IN_KB,(DATA_OBJECT_P_SIZE + INDEX_OBJECT_P_SIZE + LONG_OBJECT_P_SIZE + LOB_OBJECT_P_SIZE + XML_OBJECT_P_SIZE)/1024 AS TOTAL_SIZE_IN_MB, (DATA_OBJECT_P_SIZE + INDEX_OBJECT_P_SIZE + LONG_OBJECT_P_SIZE + LOB_OBJECT_P_SIZE + XML_OBJECT_P_SIZE) / (1024*1024) AS TOTAL_SIZE_IN_GB FROM SYSIBMADM.ADMINTABINFO WHERE TABSCHEMA NOT LIKE 'SYS%';
" > $TMP_TAB
chmod 777 $TMP_TAB
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_tablesize.out
echo $? # TODO (0 or 4)	


# List indexes which last used more than 60 days
echo "connect to ${database};
select substr(TABSCHEMA,1,20) as TAB_SCHEMA, 
substr(TABNAME,1,24) AS TAB_NAME,
substr(INDSCHEMA,1,20) as IND_SCHEMA,
substr(INDNAME,1,24) AS INDEX_NAME,
LASTUSED from syscat.indexes where LASTUSED < current timestamp - 60 days;
" > $TMP_TAB
chmod 777 $TMP_TAB
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_indexs_lastused_more_than_60days.out
echo $? # TODO (0 or 4)		

# List tables which does no run runstats in 14 days
echo "connect to ${database};
select substr(TABSCHEMA,1,20) as TAB_SCHEMA, substr(TABNAME,1,24),STATS_TIME from syscat.tables where STATS_TIME < current timestamp -14 days ;
" > $TMP_TAB
chmod 777 $TMP_TAB
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_tables_need_runstats.out
echo $? # TODO (0 or 4)

# List indexs which does no run runstats in 14 days
echo "connect to ${database};
select substr(TABSCHEMA,1,20) as TAB_SCHEMA, substr(TABNAME,1,20) AS TAB_NAME, substr(INDSCHEMA,1,20) AS INDEX_SCHEMA, substr(INDNAME,1,20) as INDEX_NAME, STATS_TIME from syscat.indexes where STATS_TIME < current timestamp - 15 days;
" > $TMP_TAB
chmod 777 $TMP_TAB
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_indexs_need_runstats.out
echo $? # TODO (0 or 4)


# List indexs info
echo "connect to ${database};
SELECT substr(TABSCHEMA,1,20) as TAB_SCHEMA, substr(TABNAME,1,20) AS TAB_NAME, substr(INDSCHEMA,1,20) AS INDEX_SCHEMA, substr(INDNAME,1,25) as INDEX_NAME, index_object_l_size, index_object_p_size, index_requires_rebuild, large_rids FROM TABLE(sysproc.admin_get_index_info('I','','')) AS t;
" > $TMP_TAB
chmod 777 $TMP_TAB
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_indexs_info.out
echo $? # TODO (0 or 4)	


# List tables rows
echo "connect to ${database};
select  substr(tabschema,1,25) as tabschema, substr(TABNAME,1,25) as TABLE_NAME, card as rows, stats_time from syscat.tables order by card desc;
" > $TMP_TAB
chmod 777 $TMP_TAB
db2 -tf $TMP_TAB > $(hostname)_${instance}_${database}_tables_rows.out
echo $? # TODO (0 or 4)	    






# TMP_MON=${WORKDIR}/ahc.${instance}.${database}.mon.sql

# # monreport.dbsummary, into host_instance_dbname_monreport.dbsummary
# # may not work in DB2 9.1, DB2 8
# echo "connect to ${database};
# call monreport.dbsummary;
# " > $TMP_MON
# chmod 777 $TMP_MON

# db2 -tf $TMP_MON > $(hostname)_${instance}_${database}_monreport.dbsummary.out

# cp -p /home/${instance}/sqllib/db2dump/db2diag.log .   # may need config
rm $TMP_TAB # $TMP_MON 


cd ${WORKDIR}
tar -cf ${Outfiles} ${WORKDIR}/db2
gzip ${Outfiles}
echo ""
echo "Output file at ${WORKDIR}/${Outfiles}.gz"
