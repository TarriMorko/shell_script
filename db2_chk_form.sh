#!/usr/bin/ksh
instname=$1
echo $instname | awk '{print toupper($0)}' | read INSTNAME
#echo instname=$instname
#echo INSTNAME=$INSTNAME
#export LC_ALL=c
export LANG=en_US
DB_LIST=`db2 list db directory |grep -i 'Database Alias' |awk '{print $4}'`
db_type_list=`db2 list db directory |grep -i 'Directory entry type' |awk '{print $5}'`

# Set cursor=0
  cursor=0
        ##do dbm command begin
echo '=== 1 =============================================================='
db2level
echo '=== 2(1),2(3) ======================================================'
lsuser db2as
cat /etc/group | grep db2asgrp
echo '=== 2(4) ==========================================================='
lsuser db2fenc1
cat /etc/group | grep db2fadm1
echo '=== 2(5) ==========================================================='
db2 get dbm cfg |grep -y group
cat /etc/group | grep db2iadm1
echo '=== 2(6) ==========================================================='
db2 get dbm cfg |grep  AUTHENTICATION
echo '=== 4(1),4(3) ======================================================'
db2audit describe
echo '=== 4(2) ==========================================================='
ls -l /home/$instname/sqllib/security/*
ls -l /home/$instname/sqllib/security/db2audit.cfg
echo '=== 5(1) ==========================================================='
db2 -v get dbm cfg |grep -y audit
echo '=== 5(2),(3) ======================================================='
db2 -v get dbm cfg |grep -y discover
echo '=== 5(4),(5) ======================================================='
db2 -v get dbm cfg |grep LEVEL
echo '=== 5(6) ==========================================================='
db2 -v get dbm cfg |grep Federated
echo '=== 5(7) ==========================================================='
db2 -v get dbm cfg |grep -y CATALOG_NOAUTH
echo '=== 5(10,11) ======================================================='
ls -dl /opt/IBM/db2
ls -dl /db2log/*/NODE0000 /db2log/db2inst1/*
ls -dl /database/cboddb/db2inst1/NODE0000/*/*/*
echo '===================================================================='

        ##do dbm command end

for db_type in ${db_type_list}
  do
    # cursor +1
    cursor=$(($cursor + 1))

    # Set db_name = cursor pointed db (ex: if cursor = 1 then db_name = the first db, etc.)
    db_name=`echo $DB_LIST |awk -v var=$cursor '{print $(var)}'`

    # If db_type == Indirect then collect db2 information for each db
    if [ ${db_type} == "Indirect" ]
      then
        db2 -v connect to $db_name

        ##do db2 command begin
echo '=== 5(8,9) ========================================================='
        db2 -v get db cfg for $db_name |grep -y log
        db2 -v get db cfg for $db_name |grep -y discover
echo '===================================================================='

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
        ##do db2 command end

        db2 -v terminate
    fi
  done
