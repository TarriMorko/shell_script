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

if [ $# -eq 0 ]; then
        echo "請輸入 instance 名稱作為參數"
        echo "ex: ./db2_security_audit.sh db2inst1"
        echo
        exit
else
        export LANG=en_US
        INSTNAME=$1
        INSTNAME_uppercase=$(echo $INSTNAME | tr 'a-z' 'A-Z')
fi

if [ -e /home/$INSTNAME/sqllib/db2profile ]; then
        . /home/$INSTNAME/sqllib/db2profile
        WORKING_DIR="/home/$INSTNAME"
        cd $WORKING_DIR
        DETAILLOG="${WORKING_DIR}/db2_security_audit_detail_$(hostname)_${INSTNAME}_$(date +"%Y%m%d_%H%M%S").txt"
        echo $DETAILLOG
        echo "DEBUG--------------------------------------"
else
        echo "Can not source db2profile. Exit."
        exit
fi

DATABASES=$( db2 list db directory | awk '/alias/{a=$NF}/Indirec/{print a}' | sed 's/ //g')

query_all_db() {
  for database in ${DATABASES}; do
#     echo "Database: $database"
    db2 connect to $database >/dev/null 2>&1
    db2 $1 | grep -q "0 record(s) selected."
    if [ $? -eq 0 ]; then
      echo "資料庫：$database ，項目通過測試。"
      echo "使用SQL:"
      echo $1
      echo ''
      echo '======================================================' >> $DETAILLOG
      echo "資料庫：$database ，項目 $2 通過測試。"  >> $DETAILLOG
      echo "使用SQL:"   >> $DETAILLOG
      echo $1   >> $DETAILLOG
      echo ''   >> $DETAILLOG
      echo ''   >> $DETAILLOG
    else
      echo "資料庫：$database ，此項目未通過測試！"
      echo "使用SQL:"
      echo $1
      echo ''
      echo '======================================================' >> $DETAILLOG
      echo "資料庫：$database ，項目 $2 未通過測試！" >> $DETAILLOG
      echo "Database: $database" >> $DETAILLOG
      db2 -v $1 >> $DETAILLOG
    fi
    db2 terminate >/dev/null 2>&1
  done
}



echo '=== 1 =============================================================='
db2level
echo '=== 2(1)============================================================'
echo 'lsuser db2as'
lsuser db2as
echo 'cat /etc/group | grep db2asgrp'
cat /etc/group | grep db2asgrp

echo '=== 2(2)============================================================'
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth" "2(2)"

echo '=== 2(3)============================================================'
echo 'lsuser db2as'
lsuser db2as
echo 'cat /etc/group | grep db2asgrp'
cat /etc/group | grep db2asgrp

echo '=== 2(4) ==========================================================='
lsuser db2fenc1
cat /etc/group | grep db2fadm1

echo '=== 2(5) ==========================================================='
db2 get dbm cfg |grep -y group
cat /etc/group | grep db2iadm1

echo '=== 2(6) ==========================================================='
db2 get dbm cfg |grep  AUTHENTICATION

        ##do dbm command end

exit

echo '===3(1)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
echo '===3(2)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
echo '===3(3)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
echo '===3(4)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
echo '===3(5)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tbspace as char(20)) as TBSPACE,USEAUTH as USE from SYSCAT.TBSPACEAUTH where grantee<>'$INSTNAME'"
echo '===3(6)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(45)) as TABLENAME, CONTROLAUTH as CTL, SELECTAUTH as SEL, INSERTAUTH as INS, UPDATEAUTH as UPD,  DELETEAUTH as DEL, ALTERAUTH as ALT, INDEXAUTH as IDX, REFAUTH as REF  from syscat.tabauth where grantee='PUBLIC' and tabschema not like 'SYS%' order by grantee"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where grantee='PUBLIC' and pkgschema <> 'NULLID'"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(indschema as char(10)) as SCHEMA, Cast(indname as char(40)) as INDNAME, CONTROLAUTH as CTL from syscat.indexauth where grantee='PUBLIC'"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(40)) as TABLENAME, Cast(colname as char(20)) as COLNAME, COLNO, PRIVTYPE, GRANTABLE  from syscat.colauth  where grantee='PUBLIC'"
db2 -v "select count(*) from syscat.passthruauth"
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(10)) as Grantee, GRANTEETYPE as GT, Cast(schemaname as char(10)) as SCHEMANAME, ALTERINAUTH as ALTERIN, CREATEINAUTH as CREATEIN, DROPINAUTH as DROPIN from SYSCAT.SCHEMAAUTH where GRANTEE='PUBLIC'" "3.6 檢測 SYSCAT.SCHEMAAUTH 結果"

echo '===3(7)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
db2 -v "select count(*) from syscat.passthruauth"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(10)) as Grantee, GRANTEETYPE as GT, Cast(schemaname as char(10)) as SCHEMANAME, ALTERINAUTH as ALTERIN, CREATEINAUTH as CREATEIN, DROPINAUTH as DROPIN from SYSCAT.SCHEMAAUTH"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(45)) as TABLENAME, CONTROLAUTH as CTL, SELECTAUTH as SEL, INSERTAUTH as INS, UPDATEAUTH as UPD,  DELETEAUTH as DEL, ALTERAUTH as ALT, INDEXAUTH as IDX, REFAUTH as REF  from syscat.tabauth  where (indexauth in ('Y','G') or refauth in ('Y','G') or controlauth in ('Y','G') or alterauth in ('Y','G')) and grantee<>'$INSTNAME'"
db2 -v "select count(*) from syscat.nicknames"
db2 -v "select Cast(grantor as char(8)) as Grantor, substr(grantee, 1,16) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where (controlauth in ('Y','G') or bindauth in ('Y','G') or executeauth in ('Y','G')) and grantee<>'$INSTNAME' and pkgschema<>'NULLID'"

echo '===3(8)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(10)) as Grantee, GRANTEETYPE as GT, Cast(schemaname as char(10)) as SCHEMANAME, ALTERINAUTH as ALTERIN, CREATEINAUTH as CREATEIN, DROPINAUTH as DROPIN from SYSCAT.SCHEMAAUTH"
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(45)) as TABLENAME, CONTROLAUTH as CTL, SELECTAUTH as SEL, INSERTAUTH as INS, UPDATEAUTH as UPD,  DELETEAUTH as DEL, ALTERAUTH as ALT, INDEXAUTH as IDX, REFAUTH as REF  from syscat.tabauth  where (indexauth in ('Y','G') or refauth in ('Y','G') or controlauth in ('Y','G') or alterauth in ('Y','G')) and grantee<>'$INSTNAME'"
db2 -v "select count(*) from syscat.nicknames"
db2 -v "select Cast(grantor as char(8)) as Grantor, substr(grantee, 1,16) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where (controlauth in ('Y','G') or bindauth in ('Y','G') or executeauth in ('Y','G')) and grantee<>'$INSTNAME' and pkgschema<>'NULLID'"

echo '=== 4(1)============================================================'
db2audit describe

echo '=== 4(2) ==========================================================='
ls -l /home/$instname/sqllib/security/auditdata/files/datapath/*
ls -l /home/$instname/sqllib/security/db2audit.cfg

echo '=== 4(3)============================================================'
db2audit describe

echo '=== 5(1) ==========================================================='
db2 -v get dbm cfg |grep -y audit
echo '=== 5(2)============================================================'
db2 -v get dbm cfg |grep -y discover
echo '=== 5(3)============================================================'
db2 -v get dbm cfg |grep -y discover
echo '=== 5(4)============================================================'
db2 -v get dbm cfg |grep LEVEL
echo '=== 5(5)============================================================'
db2 -v get dbm cfg |grep LEVEL
echo '=== 5(6) ==========================================================='
db2 -v get dbm cfg |grep Federated
echo '=== 5(7) ==========================================================='
db2 -v get dbm cfg |grep -y CATALOG_NOAUTH
echo '=== 5(8)============================================================'
        db2 -v get db cfg for $db_name |grep -y log
        db2 -v get db cfg for $db_name |grep -y discover
echo '=== 5(9)============================================================'
        db2 -v get db cfg for $db_name |grep -y log
        db2 -v get db cfg for $db_name |grep -y discover
echo '=== 5(10)==========================================================='
ls -dl /opt/IBM/db2
ls -dl /db2log/*/NODE0000 /archivelog/*/$instname/*
ls -dl /database/*db/$instname/NODE0000/*/T*/*
echo '=== 5(11)==========================================================='
ls -dl /opt/IBM/db2
ls -dl /db2log/*/NODE0000 /archivelog/*/$instname/*
ls -dl /database/*db/$instname/NODE0000/*/T*/*
echo '===================================================================='


exit















echo '=== ROLE Members ====================================='
db2 -v "select Cast(GRANTOR as char(8)) as Grantor, GRANTORTYPE, Cast(GRANTEE as char(20)) as Grantee, GRANTEETYPE, Cast(ROLENAME as char(20)) as RoleName, ROLEID from syscat.roleauth where GRANTOR <> 'SYSIBM'"
echo '===================================================================='


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

db2 -v "select Cast(grantor as char(8)) as Grantor, substr(grantee, 1,16) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where (controlauth in ('Y','G') or bindauth in ('Y','G') or executeauth in ('Y','G')) and grantee<>'$INSTNAME' and pkgschema<>'NULLID'"

echo '###########################################################################################'
        ##do db2 command end

        db2 -v terminate
    fi
  done














# 暫存區
echo '=== 3(6)-7,3(7),3(8) ==============================================='

3(1),3(2),3(3),3(4),3(6)-1,3(7)
echo '===3(1)============================================================='
echo '===3(2)============================================================='
echo '===3(3)============================================================='
echo '===3(4)============================================================='
echo '===3(5)============================================================='
echo '===3(6)============================================================='
echo '===3(7)============================================================='
echo '===3(8)============================================================='
echo '===3(1)============================================================='
db2 -v "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(20)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO, CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"
