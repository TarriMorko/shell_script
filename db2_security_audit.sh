#!/usr/bin/ksh
#
#


# DEBUG 需事先填入 AP 使用的帳號
# DEBUG 也許可以利用 /etc/passwd UID > 多少來判斷
ALL_AP_ACCOUNT="MAX MAX1"   # DEBUG
ALL_DBA_ACCOUNT="SPDB1 SPDB2"


ALL_AP_ACCOUNT=$(echo $ALL_AP_ACCOUNT | tr 'a-z' 'A-Z')
ALL_DBA_ACCOUNT=$(echo $ALL_DBA_ACCOUNT | tr 'a-z' 'A-Z')


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
    else
      echo "資料庫：$database ，此項目未通過測試！"
      echo '======================================================' >> $DETAILLOG
      echo "資料庫：$database ，項目 $2 未通過測試！" >> $DETAILLOG
      echo "Database: $database" >> $DETAILLOG
      db2 -v $1 >> $DETAILLOG
    fi
    db2 terminate >/dev/null 2>&1
  done
}


echo ''
echo '1.軟體版本與資料 ======================================================'

cat <<rule_1.1


編號 1.1 
檢查目的：軟體版本更新
檢查方式：輸入指令"db2level"，檢查目前使用之版本與修補版本狀況
安裝半年前最新版且穩定之修補程式

檢查結果：
rule_1.1

db2level

echo ''
echo '2.DB2之存取控制 ======================================================='

cat <<rule_2.1


編號 2.1
檢查目的：DAS管理特權應僅由資料庫管理人員帳號持有
檢查方式：DAS管理特權應僅由資料庫管理人員帳號持有

檢查結果：
rule_2.1

lsuser -f db2as
lsgroup -f db2asgrp
# cat /etc/group | grep db2asgrp

cat <<rule_2.2


編號 2.2
檢查目的：停用或關閉不必要之帳號
檢查方式：檢視資料庫/「使用者與群組物件」中，各案例資料庫中之使用者，確認其權限之適當性
        停用或關閉所有不應使用之系統預設帳號(如Guest)、廠商帳號與無法辨識之使用者帳號。

檢查結果：
rule_2.2

# DEBUG
# query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as CO , CREATETABAUTH as CT, BINDADDAUTH as BA, NOFENCEAUTH as NF, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IS, LOADAUTH as LO, EXTERNALROUTINEAUTH as ER, QUIESCECONNECTAUTH as QC from syscat.dbauth"

cat <<rule_2.3


編號 2.3
檢查目的：Administration Server帳號授權
檢查方式：檢視Administration Server之帳號於作業系統內之權限
        給予最小之權限。如於Windows之權限應等同db2adm之權限；
        於Unix權限應等同owner是dasusr1的目錄（含子目錄）及檔案

檢查結果：
rule_2.3

lsuser db2as
cat /etc/group | grep db2asgrp

cat <<rule_2.4


編號 2.4
檢查目的：UNIX系統DB2 fenced user僅配置最低OS權限
檢查方式：僅給予存取根目錄下的權限(read/execute permissions to files stored in its homedirectory)與登入系統(log into the server)之權限

檢查結果：
rule_2.4

lsuser db2fenc1
cat /etc/group | grep db2fadm1

cat <<rule_2.5


編號 2.5
檢查目的：SYSADM,SYSCTRL,與SYSMAINT權限設定
檢查方式：只有授權之DBAs群組帳號才能配置SYSADM_Group, SYSCTR_Group, 與 SYSMAINT_Group權限

檢查結果：
rule_2.5


echo ""
echo "SYSADM group:" $(db2 get dbm cfg | grep SYSADM_GROUP | awk '{print $NF}')
cat /etc/group | grep -y $(db2 get dbm cfg | grep SYSADM_GROUP | awk '{print $NF}')
echo ""
echo "SYSCTRL group:" $(db2 get dbm cfg | grep SYSCTRL_GROUP | awk '{print $NF}')
cat /etc/group | grep -y $(db2 get dbm cfg | grep SYSCTRL_GROUP | awk '{print $NF}')
echo ""
echo "SYSMAINT group:" $(db2 get dbm cfg | grep SYSMAINT_GROUP | awk '{print $NF}')
cat /etc/group | grep -y $(db2 get dbm cfg | grep SYSMAINT_GROUP | awk '{print $NF}')
echo ""
echo "SYSMON group:" $(db2 get dbm cfg | grep SYSMON_GROUP | awk '{print $NF}')
cat /etc/group | grep -y $(db2 get dbm cfg | grep SYSMON_GROUP | awk '{print $NF}')
echo ""




cat <<rule_2.6


編號 2.6
檢查目的：身份驗證方式
檢查方式：資料庫管理員須確認案例(instance)之身份驗證方式設定為SERVER、 SERER_ENCRYPT、KERBEROS 或 KERBEROS_ENCRYPT

檢查結果：
rule_2.6

db2 get dbm cfg | grep AUTHENTICATION

echo ''
echo '3.授權 ================================================================'



cat <<rule_3.1
編號 3.1
檢查目的：DBADM權限
檢查方式：檢視擁有DBADM權限(Authorities項目皆勾選)之使用者代碼(USER-ID)帳號與群組為已授權之DBAs或該應用之擁有者

檢查結果：
rule_3.1
echo "$INSTNAME_uppercase" "debug"
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, DBADMAUTH as DBADM from syscat.dbauth where GRANTEE <> '${INSTNAME_uppercase}' and DBADMAUTH = 'Y'" "3.1"


cat <<rule_3.2
編號 3.2
檢查目的：應用程式帳號權限
檢查方式：檢視資料庫/「使用者與群組物件」中，各案例資料庫中之使用者，確認其權限之適當性
        只授予應用程式帳號CONNECT資料庫特權

檢查結果：
rule_3.2
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as connect from syscat.dbauth where  GRANTEE <> '${INSTNAME_uppercase}' $( for i in $ALL_AP_ACCOUNT ; do echo "AND GRANTEE <> '$i'"; done)" "3.2"



cat <<rule_3.3
編號 3.3
檢查目的：PUBLIC角色
檢查方式：檢視資料庫/「使用者與群組物件」中， PUBLIC權限
        撤銷 CONNECT、CREATETAB、BINDADD、IMPLICIT_SCHEMA下權限

檢查結果：
rule_3.3
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE, CONNECTAUTH as CONNECT, CREATETABAUTH as CREATETAB, BINDADDAUTH as BINDADD, IMPLSCHEMAAUTH as IMPLICIT_SCHEMA from syscat.dbauth where Grantee ='PUBLIC' AND (CONNECTAUTH='Y' or CREATETABAUTH='Y' or BINDADDAUTH='Y' or IMPLSCHEMAAUTH='Y')" "3.3"






cat <<rule_3.4
編號 3.4
檢查目的： CREATE_NOT_FENCED 權限
檢查方式：檢視資料庫/「使用者與群組物件」中，各案例資料庫中之使用者之「Database」權限
        清除「Register routines to execute in database manager’s process」勾選項目，以限制CREATE_NOT_FENCED權限之分派

檢查結果：
rule_3.4
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE, NOFENCEAUTH as CREATE_NOT_FENCED from syscat.dbauth where GRANTEE <> '${INSTNAME_uppercase}' AND NOFENCEAUTH='Y'" "3.4"




cat <<rule_3.5
編號 3.5
檢查目的：應限制Tablespace內PUBLIC持有之物件權限
檢查方式：檢視各Tablespace設定
        移除PUBLIC持有之CREATEIN、USE物件權限

檢查結果：
rule_3.5
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tbspace as char(20)) as TBSPACE,USEAUTH as USE from SYSCAT.TBSPACEAUTH where GRANTEE <> '${INSTNAME_uppercase}' " "3.5"





cat <<rule_3.6


編號 3.6
檢查目的：應限制系統目錄(system catalog)、資料表(tables)及檢視(views)中PUBLIC持有之權限
檢查方式：檢視系統目錄、資料表及檢視設定
        移除以下PUBLIC持有之權限：
        - SYSCAT.DBAUTH
        - SYSCAT.TABAUTH
        - SYSCAT.PACKAGEAUTH
        - SYSCAT.INDEXAUTH
        - SYSCAT.COLAUTH
        - SYSCAT.PASSTHRUAUTH
        - SYSCAT.SCHEMAAUTH 

檢查結果：


rule_3.6

echo ""
echo "檢測 SYSCAT.dbauth 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, CONNECTAUTH as connect , CREATETABAUTH as CREATETAB, BINDADDAUTH as BINDADD, NOFENCEAUTH as NO_FENCE, DBADMAUTH as DBADM, IMPLSCHEMAAUTH as IMPLSCHEMA, LOADAUTH as LOAD, EXTERNALROUTINEAUTH as EXTERNAL_ROUTINE, QUIESCECONNECTAUTH as QUIESCE_CONNECT from syscat.dbauth where Grantee='PUBLIC'" "3.6 檢測 SYSCAT.dbauth 結果 "



echo ""
echo "檢測 SYSCAT.tabauth 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(45)) as TABLENAME, CONTROLAUTH as CTL, SELECTAUTH as SEL, INSERTAUTH as INS, UPDATEAUTH as UPD, DELETEAUTH as DEL, ALTERAUTH as ALT, INDEXAUTH as IDX, REFAUTH as REF from syscat.tabauth where grantee='PUBLIC' and tabschema not like 'SYS%' AND (CONTROLAUTH='Y' or SELECTAUTH='Y' or INSERTAUTH='Y' or UPDATEAUTH='Y' or DELETEAUTH='Y' or ALTERAUTH='Y' or ALTERAUTH='Y' or INDEXAUTH='Y' or REFAUTH='Y')" "3.6 檢測 SYSCAT.tabauth 結果 "


echo ""
echo "檢測 SYSCAT.packageauth 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(pkgschema as char(10)) as SCHEMA, Cast(pkgname as char(24)) as PKGNAME, CONTROLAUTH as CTL, BINDAUTH as BA, EXECUTEAUTH as EX from syscat.packageauth where grantee='PUBLIC' and pkgschema<>'NULLID'" "3.6 檢測 SYSCAT.packageauth 結果 "


echo ""
echo "檢測 SYSCAT.indexauth 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(indschema as char(10)) as SCHEMA, Cast(indname as char(40)) as INDNAME, CONTROLAUTH as CTL from syscat.indexauth where grantee='PUBLIC'" "3.6 檢測 SYSCAT.indexauth 結果 "


echo ""
echo "檢測 SYSCAT.colauth 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE as GT, Cast(tabschema as char(10)) as SCHEMA, Cast(tabname as char(40)) as TABLENAME, Cast(colname as char(20)) as COLNAME, COLNO, PRIVTYPE, GRANTABLE from syscat.colauth where grantee='PUBLIC' and tabschema not like 'SYS%'" "3.6 檢測 SYSCAT.colauth 結果"


echo ""
echo "檢測 SYSCAT.passthruauth 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(8)) as Grantee, GRANTEETYPE, substr(SERVERNAME,1,20) as SERVERNAME from syscat.passthruauth" "3.6 檢測 SYSCAT.passthruauth 結果"


echo ""
echo "檢測 SYSCAT.SCHEMAAUTH 結果："
query_all_db "select Cast(grantor as char(8)) as Grantor, Cast(grantee as char(10)) as Grantee, GRANTEETYPE as GT, Cast(schemaname as char(10)) as SCHEMANAME, ALTERINAUTH as ALTERIN, CREATEINAUTH as CREATEIN, DROPINAUTH as DROPIN from SYSCAT.SCHEMAAUTH where GRANTEE='PUBLIC'" "3.6 檢測 SYSCAT.SCHEMAAUTH 結果"





cat <<rule_3.7


編號 3.7
檢查目的：重要物件特權應限制其分派
檢查方式：檢視以下物件之權限分派狀況：
        (1) 僅能由資料庫管理人員帳號持有者：
        - Alterin (schema) (或限制具BINDADD執行者擁有)
        - Index (tables, nicknames)
        - Createin (schema) (或限制具BINDADD執行者擁有)
        - References (tables, nicknames)
        - Dropin (schema)- Passthru (server) 
        - All (tables, views, nicknames)
        - Usage (sequences) 
        - Alter (tables, views, nicknames)
        - Control (sequences, nicknames, packages, procedures, functions, methods, tables, views, tablespaces) (或限制具Createin (schema)執行者擁有control packages權限)
        (2) 指派給資料庫管理人員與一般應用程式使用帳號
        -Delete (tables, views)
        -Insert (tables, views)
        -Update (tables, views)
        -Select (tables, views)
        -Execute (packages, procedures, functions, methods)


檢查結果：
rule_3.7


echo "檢測 Alterin 結果："
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '${INSTNAME_uppercase}'              AND AUTHIDTYPE='U' AND PRIVILEGE='ALTERIN' and OBJECTTYPE='SCHEMA' AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID' $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 檢測 Alterin 結果"


echo "檢測 Index (tables, nicknames) 結果"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '${INSTNAME_uppercase}' AND AUTHIDTYPE='U' AND PRIVILEGE='INDEX' and (OBJECTTYPE='TABLE' or OBJECTTYPE='NICKNAME') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID' $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 檢測 Index (tables, nicknames) 結果"


echo "檢測 Createin (schema) 結果"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '${INSTNAME_uppercase}' AND AUTHIDTYPE='U' AND PRIVILEGE='CREATEIN' and OBJECTTYPE='SCHEMA' AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID' $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 檢測 Createin (schema) 結果 "



echo "檢測 References (tables, nicknames)  結果"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '${INSTNAME_uppercase}' AND AUTHIDTYPE='U' AND PRIVILEGE='REFERENCE'and (OBJECTTYPE='TABLE' or OBJECTTYPE='NICKNAME') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'   $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 檢測 References (tables, nicknames) 結果 "




echo "檢測 Dropin (schema)- Passthru (server) 結果"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '${INSTNAME_uppercase}' AND AUTHIDTYPE='U' AND PRIVILEGE='DROPIN' and OBJECTTYPE='SCHEMA' AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'   $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 檢測 Dropin (schema)- Passthru (server) 結果 "




echo "檢測 Usage (sequences)  結果"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '${INSTNAME_uppercase}' AND AUTHIDTYPE='U' AND PRIVILEGE='USAGE' and OBJECTTYPE='SEQUENCE'  AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'   $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 檢測 Usage (sequences) 結果 "



echo ""
echo "Alter (tables, views, nicknames) (1) 僅能由資料庫管理人員帳號持有。"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='ALTER' AND (OBJECTTYPE='TABLE' or OBJECTTYPE='NICKNAME' or OBJECTTYPE='VIEW') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID' $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" echo "3.7 Alter (tables, views, nicknames) (1) 僅能由資料庫管理人員帳號持有。"




echo ""
echo "Control (sequences, nicknames, packages, procedures, functions, methods, tables, views, tablespaces) (或限制具Createin (schema)執行者擁有control packages權限) (1) 僅能由資料庫管理人員帳號持有。"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='CONTROL' AND (OBJECTTYPE='SEQUENCE'or OBJECTTYPE='NICKNAME'or OBJECTTYPE LIKE '%PACKAGE%' or OBJECTTYPE='PROCEDURE'or OBJECTTYPE='FUNCTION'or OBJECTTYPE='METHOD'or OBJECTTYPE='TABLE'or OBJECTTYPE='VIEW'or OBJECTTYPE='TABLESPACE') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID' $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 Control (sequences, nicknames, packages, procedures, functions, methods, tables, views, tablespaces) (或限制具Createin (schema)執行者擁有control packages權限) (1) 僅能由資料庫管理人員帳號持有。"



echo ""
echo "Delete (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='DELETE' AND (OBJECTTYPE='TABLE' or OBJECTTYPE='VIEW') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID' $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 Delete (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"



echo ""
echo "Insert (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='INSERT' AND (OBJECTTYPE='TABLE' or OBJECTTYPE='VIEW') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'  $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 Insert (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"


echo ""
echo "Update (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='UPDATE' AND (OBJECTTYPE='TABLE' or OBJECTTYPE='VIEW') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'  $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 Update (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"


echo ""
echo "Select (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='SELECT' AND (OBJECTTYPE='TABLE' or OBJECTTYPE='VIEW') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'  $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 Select (tables, views) (2) 指派給資料庫管理人員與一般應用程式使用帳號"


echo ""
echo "Execute (packages, procedures, functions, methods) (2) 指派給資料庫管理人員與一般應用程式使用帳號"
query_all_db "select substr(authid,1,20) as authid, authidtype, privilege, grantable, substr(objectschema,1,12) as objectschema, substr(objectname,1,30) as objectname, objecttype from sysibmadm.privileges where AUTHID <> '$INSTNAME_uppercase' AND AUTHIDTYPE='U' AND PRIVILEGE='EXECUTE' AND (OBJECTTYPE LIKE '%PACKAGE%' or OBJECTTYPE='PROCEDURE' or OBJECTTYPE='VIEW' or OBJECTTYPE='FUNCTION' or OBJECTTYPE='METHOD') AND OBJECTSCHEMA not like 'SYS%' AND OBJECTSCHEMA <> 'NULLID'  $( for i in $ALL_DBA_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done) $( for i in $ALL_AP_ACCOUNT ; do echo "AND AUTHID <> '$i'"; done)" "3.7 Execute (packages, procedures, functions, methods) (2) 指派給資料庫管理人員與一般應用程式使用帳號"



cat <<rule_3.8


cat <<rule_3.8
編號 3.8
檢查目的：應限制應用程式帳號持有之物件權限
檢查方式：檢視資料庫內應用程式帳號，應移除以下物件權限：
        WITH GRANT OPTION
檢查結果：
        同 3.7
rule_3.8

echo '' 
echo '4.稽核軌跡（重要系統資料庫適用）======================================='

cat <<rule_4.1


編號 4.1
檢查目的：啟動稽核軌跡
檢查方式：輸入以下指令，並檢視結果：
        db2audit describe
        Audit active= "TRUE"

檢查結果：
rule_4.1

db2audit describe | grep "Audit active" 

cat <<rule_4.2


編號 4.2
檢查目的：保護稽核軌跡與其設定檔
檢查方式：檢視以下檔案之權限，是否僅由授權帳號可存取： 
        db2audit.log
        db2audit.cfg

檢查結果：
rule_4.2

echo ""
echo "db2audit.log"
find ~ -name "db2audit.log" -exec ls -al {} \;
echo ""
echo "db2audit.cfg"
find ~ -name "db2audit.cfg" -exec ls -al {} \;

cat <<rule_4.3


編號 4.3
檢查目的：稽核軌跡之設置
檢查方式：輸入以下指令，檢視結果：
        db2audit describe
        設定日誌系統管理員事件 (SYSADMIN) - 成功與失敗。

檢查結果：
rule_4.3
db2audit describe | grep "Log system administrator events"



echo '5.參數設定 ============================================================'

cat <<rule_5.1


編號 5.1
檢查目的：稽核軌跡容量設置
檢查方式：檢視各Instance之audit-buf-sz參數設定
        至少設定為512

檢查結果：
rule_5.1

db2 get dbm cfg | grep AUDIT_BUF_SZ

cat <<rule_5.2


編號 5.2
檢查目的：關閉Discovery Mode
檢查方式：檢視各Instance其discover參數設定
        設定為disable

檢查結果：
rule_5.2

db2 get dbm cfg | grep '(DISCOVER)'

cat <<rule_5.3


編號 5.3
檢查目的：關閉Discover Server Instance
檢查方式：檢視discover_inst參數設定
        設定為disable

檢查結果：
rule_5.3

db2 get dbm cfg | grep '(DISCOVER_INST)'

cat <<rule_5.4


編號 5.4
檢查目的：開啟Diagnostics Error Capture Level
檢查方式：檢視diaglevel參數設定
        設定為3

檢查結果：
rule_5.4

db2 get dbm cfg | grep '(DIAGLEVEL)'

cat <<rule_5.5


編號 5.5
檢查目的：設定Notify Level
檢查方式：檢視notifylevel參數設定
        設定為3 

檢查結果：
rule_5.5
db2 get dbm cfg | grep '(NOTIFYLEVEL)'

cat <<rule_5.6


編號 5.6
檢查目的：關閉請求遠端資料庫功能
檢查方式：檢視federated參數設定
        設定為No

檢查結果：
rule_5.6
db2 get dbm cfg | grep '(FEDERATED)'

cat <<rule_5.7


編號 5.7
檢查目的：限制非SYSADM權限對資料庫進行目錄化
檢查方式：檢視catalog_noauth參數設定，
        設定為No或 0

檢查結果：
rule_5.7
db2 get dbm cfg | grep '(CATALOG_NOAUTH)'

cat <<rule_5.8


編號 5.8
檢查目的：有可能執行ROLLFORWARD RECOVERY作業之資料庫，應將LOG ARCHIVE到磁碟
檢查方式：檢視logretain、userexit參數設定
        logretain設定為RECOVERY；userexit設定為YES或LOGARCHMETH1 = DISK:/”目錄”/

檢查結果：
rule_5.8

for database in ${DATABASES}; do
        echo "Database: $database"
        db2 connect to $database >/dev/null 2>&1
        echo ""
        db2 get db cfg | grep -i '(LOGARCHMETH1)'
        echo ""
        db2 terminate >/dev/null 2>&1
done

cat <<rule_5.9


編號 5.9
檢查目的：關閉Discover Database
檢查方式：檢視discover_db參數設定
        設定為DISABLE

檢查結果：
rule_5.9

for database in ${DATABASES}; do
        echo "Database: $database"
        db2 connect to $database >/dev/null 2>&1
        echo ""
        db2 get db cfg | grep -i '(DISCOVER_DB)'
        echo ""
        db2 terminate >/dev/null 2>&1
done

cat <<rule_5.10


編號 5.10
檢查目的：DB2相關檔案與目錄擁有者設定
檢查方式：檢視DB2目錄與檔案，Owner應僅能為以下：
        DB2 instance 擁有者
        DB2 fenced user
        DAS 帳號

檢查結果：
rule_5.10

ls -al ~

cat <<rule_5.11


編號 5.11
檢查目的：DB2目錄控制權
檢查方式：檢視DB2系統安裝及資料庫所在目錄，權限應僅指派給Administrator與DB2安裝帳號。

檢查結果：
rule_5.11

ls -ald /opt/*/db2
