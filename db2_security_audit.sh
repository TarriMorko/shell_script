#!/usr/bin/ksh
#
#

instname=$1
echo $instname | awk '{print toupper($0)}' | read INSTNAME
export LANG=en_US
# export LC_ALL=POSIX
# export LANG=POSIX

# TODO 要加一個檢測 db2pd 執行失敗的函式 (檢查權限不夠、或沒有 source db2profile 等錯誤)

# DB_LIST=$(db2 list db directory | grep -i 'Database Alias' | awk '{print $4}')
# db_type_list=$(db2 list db directory | grep -i 'Directory entry type' | awk '{print $5}')
WORKING_DIR="/home/inst411"
cd $WORKING_DIR

DATABASES=$(
  db2 list db directory | awk '/alias/{a=$NF}/Indirect/{print a}' | sed 's/ //g'
)
echo $DATABASES

# SYSADM_GROUP=$(db2 get dbm cfg | grep -i SYSADM_GROUP | awk -F'=' '{print $NF}')
# SYSCTRL_GROUP=$(db2 get dbm cfg | grep -i SYSCTRL_GROUP | awk -F'=' '{print $NF}')
# SYSMAINT_GROUP=$(db2 get dbm cfg | grep -i SYSMAINT_GROUP | awk -F'=' '{print $NF}')
# SYSMON_GROUP=$(db2 get dbm cfg | grep -i SYSMON_GROUP | awk -F'=' '{print $NF}')
# echo "DEBUG: " $SYSADM_GROUP                                      # DEBUG
# cat /etc/group | grep -i $SYSADM_GROUP | awk -F':' '{print $NF}'  # 除了建 instance 的那個人以外，擁有 sysadm 權限者
# cat /etc/group | grep -i $SYSCTRL_GROUP | awk -F':' '{print $NF}' #
# cat /etc/group | grep -i $SYSMAINT_GROUP | awk -F':' '{print $NF}'
# cat /etc/group | grep -i $SYSMON_GROUP | awk -F':' '{print $NF}'

# echo '=== 1 =============================================================='
# db2level
# echo '=== 2(1),2(3) ======================================================'
# lsuser db2as # TODO linux 要改成同時適合 AIX 跟 Linux 用的
# cat /etc/group | grep db2asgrp
# echo '=== 2(4) ==========================================================='
# lsuser db2fenc1 # TODO linux 要改成同時適合 AIX 跟 Linux 用的
# cat /etc/group | grep db2fadm1
# echo '=== 2(5) ==========================================================='
# db2 get dbm cfg | grep -y group
# cat /etc/group | grep db2iadm1
# echo '=== 2(6) ==========================================================='
# db2 get dbm cfg | grep AUTHENTICATION
# echo '=== 4(1),4(3) ======================================================'
# db2audit describe
# echo '=== 4(2) ==========================================================='
# ls -l /home/$instname/sqllib/security/*  # TODO 需要確認這裡是不是固定位置
# ls -l /home/$instname/sqllib/security/db2audit.cfg # TODO 需要確認這裡是不是固定位置
# echo '=== 5(1) ==========================================================='
# db2 -v get dbm cfg |grep -y audit
# echo '=== 5(2),(3) ======================================================='
# db2 -v get dbm cfg |grep -y discover
# echo '=== 5(4),(5) ======================================================='
# db2 -v get dbm cfg |grep LEVEL
# echo '=== 5(6) ==========================================================='
# db2 -v get dbm cfg |grep Federated
# echo '=== 5(7) ==========================================================='
# db2 -v get dbm cfg |grep -y CATALOG_NOAUTH
# echo '=== 5(10,11) ======================================================='
# ls -dl /opt/IBM/db2                                     # TODO 不知道這項是要檢查什麼，需要修正路徑位置
# ls -dl /db2log/*/NODE0000 /db2log/db2inst1/*            # TODO 不知道這項是要檢查什麼，需要修正路徑位置
# ls -dl /database/cboddb/db2inst1/NODE0000/*/*/*         # TODO 不知道這項是要檢查什麼，需要修正路徑位置
# echo '===================================================================='

        ##do dbm command end


for db_name in ${DATABASES}; do
  db2 -v connect to $db_name
  echo '=== 5(8,9) ========================================================='
          db2 -v get db cfg for $db_name |grep -y log
          db2 -v get db cfg for $db_name |grep -y discover
  echo '===================================================================='
  echo '===================================================================='
  # TODO 下面這一段要改成新版的
  echo '=== 2(2),3(1),3(2),3(3),3(4),3(6)-1,3(7)==================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO , CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
  echo '=== 3(5) ==========================================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tbspace as char(20)) as TBSPACE,USEAUTH as USE from SYSCAT.TBSPACEAUTH where grantee<>'$INSTNAME'"
  echo '=== 3(6)-2 ========================================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(45)) as TABLENAME, CONTROLAUTH as CTL, SELECTAUTH as SEL, INSERTAUTH as INS, UPDATEAUTH as UPD,  DELETEAUTH as DEL, ALTERAUTH as ALT, INDEXAUTH as IDX, REFAUTH as REF  from syscat.tabauth where grantee='PUBLIC' and tabschema not like 'SYS%' order by grantee"
  echo '=== 3(6)-3 ========================================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where grantee='PUBLIC' and pkgschema <> 'NULLID'"
  echo '=== 3(6)-4 ========================================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(indschema as char(10)) as SCHEMA, Cast(indname as char(40)) as INDNAME, CONTROLAUTH as CTL from syscat.indexauth where grantee='PUBLIC'"
  echo '=== 3(6)-5 ========================================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(40)) as TABLENAME, Cast(colname as char(20)) as COLNAME, COLNO, PRIVTYPE, GRANTABLE  from syscat.colauth  where grantee='PUBLIC'"
  echo '=== 3(6)-6,3(7) ===================================================='
  db2 -v "select count(*) from syscat.passthruauth"
  echo '=== 3(6)-7,3(7),3(8) ==============================================='
  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(10)) as Grantee, GRANTEETYPE as GT, Cast(schemaname as char(10)) as SCHEMANAME, ALTERINAUTH as ALTERIN, CREATEINAUTH as CREATEIN, DROPINAUTH as DROPIN from SYSCAT.SCHEMAAUTH"

  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(45)) as TABLENAME, CONTROLAUTH as CTL, SELECTAUTH as SEL, INSERTAUTH as INS, UPDATEAUTH as UPD,  DELETEAUTH as DEL, ALTERAUTH as ALT, INDEXAUTH as IDX, REFAUTH as REF  from syscat.tabauth  where (indexauth in ('Y','G') or refauth in ('Y','G') or controlauth in ('Y','G') or alterauth in ('Y','G')) and grantee<>'$INSTNAME'"

  db2 -v "select count(*) from syscat.nicknames"

  db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where (controlauth in ('Y','G') or bindauth in ('Y','G') or executeauth in ('Y','G')) and grantee<>'$INSTNAME' and pkgschema<>'NULLID'"

  echo '###########################################################################################'
  db2 -v terminate
done
