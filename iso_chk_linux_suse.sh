#!/bin/ksh
wrkdir=/home/spos2
hname=`hostname`
outfil=/home/spos2/$hname.iso_chk_linux.txt
echo "############################"  > $outfil
echo "# LINUX系統強化檢核表附件  #" >> $outfil
echo "#        第一次強化        #" >> $outfil
echo "############################"  >> $outfil
echo "  " >> $outfil
echo  Hostname: $hname >> $outfil
echo "  " >> $outfil
echo "1-1 登錄畫面的welcome message是否含有系統資訊？" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/issue" >> $outfil
cat /etc/issue >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "cat /etc/issue.net" >> $outfil
cat /etc/issue.net >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

 
echo "2-1 確認密碼品質依管理要點設定？" >> $outfil
echo "==================================" >> $outfil
echo "OS 版本 SuSE12 檔案擺放位置不同於 SuSE 10、11，檔案名為 pam-config，但功能與參數相同。"  >> $outfil


echo " cat /etc/login.defs|grep PASS_MAX_DAYS"  >> $outfil
cat /etc/login.defs|grep PASS_MAX_DAYS |grep -v "^#" >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "pam-config -q --cracklib" >> $outfil 
pam-config -q --cracklib >> $outfil
echo "----------------------------------" >> $outfil
echo "pam-config -q --pwhistory ">> $outfil
pam-config -q --pwhistory >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-2 確認使用者帳號的可辨別性？" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/passwd "  >> $outfil
cat /etc/passwd   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-3確認root帳號之管理是否適當？ " >> $outfil
echo "==================================" >> $outfil
echo "2-3-2 確認/etc/passwd及/etc/group，root之uid及gid "  >> $outfil
echo "同 2-2 /etc/passwd 檔" >> $outfil
echo "----------------------------------" >> $outfil
echo " cat /etc/group  "  >> $outfil
cat /etc/group   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-3-3 列出/etc/passwd及/etc/group中，uid及gid為0的所有使用者"  >> $outfil
echo "==================================" >> $outfil
cat /etc/passwd |grep ':0:0' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-4 確認不必要系統預設帳號是否移除或鎖定 " >> $outfil
echo "==================================" >> $outfil
echo "2-4-1 檢查/etc/passwd帳號列表，是否留有guest帳號？ "  >> $outfil
id guest >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "本系統有 GUEST 帳號。" >> $outfil
else
    echo "本系統無 GUEST 帳號。" >> $outfil
fi
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-4-2 列示廠商使用之帳號 "  >> $outfil
echo "==================================" >> $outfil
echo "如2-2 /etc/passwd 檔"  >> $outfil
echo "無廠商使用之帳號"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

echo "2-4-3 列示所有系統預設帳號" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/passwd |awk 'FS=":"  {print $1,$3}'|awk '$2 < 200 {print $1}'"  >> $outfil
cat /etc/passwd |awk 'FS=":"  {print $1,$3}'|awk '$2 < 200 {print $1}'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-5 一般帳號管理" >> $outfil
echo "==================================" >> $outfil
echo "2-5-1,2 cat /etc/passwd "  >> $outfil
echo "同 2-2 /etc/passwd 檔" >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-5-3 檢查是否有不需密碼即可登入的帳號 "  >> $outfil
echo "OS 版本 SuSE12 無 login -P 指令，改 passwd -S \(帳號\) 檢查是否有不需密碼即可登入的帳號" >> $outfil
echo " 說明:LK為鎖定，PS需密碼登入，NP不需密碼登入" >> $outfil
echo " cat /etc/passwd | awk -F':' '{print $1}' | xargs -I {} passwd -S {} | awk '{print $1, $2}'" >> $outfil
cat /etc/passwd | awk -F':' '{print $1}' | xargs -I {} passwd -S {} | awk '{print $1, $2}' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-6 確認強迫使用者未任何動作超過一定時間時，予以強迫登出？" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep LOGIN_TIMEOUT"  >> $outfil
cat /etc/login.defs |grep LOGIN_TIMEOUT >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

echo "2-7 確認系統預設使用者帳號的umask值" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep UMASK |grep 027"  >> $outfil
cat /etc/login.defs |grep UMASK |grep 027 >> $outfil
echo "----------------------------------" >> $outfil
echo "cat /root/.profile |grep umask"  >> $outfil
cat /root/.profile |grep umask  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-8 檢查root登入時是否執行非root的程式?"  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /root/.profile" >> $outfil
ls -l /root/.profile >> $outfil
cat /root/.profile  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-9 確認是否關閉不必需要登入權限的系統預設帳號"  >> $outfil
echo "==================================" >> $outfil
# 確認adm, bin, daemon, listen, lp, nobody, noaccess, nuucp, smtp, sys, uucp等帳號皆已停用且不具備login shell。
system_default_accouts=(adm bin daemon listen lp nobody noaccess nuucp smtp sys uucp)
for system_default_accout in ${system_default_accouts[@]}; do
    login_sh=$(awk -v S=$system_default_accout -F':' '$1 == S {print $NF}' /etc/passwd)
    if [[ -z "$login_sh" ]]; then
        echo "本系統無 $system_default_accout 帳號。"  >> $outfil
    else
        if 	[ "$login_sh" == "/bin/false" ]; then
            echo "本系統有 $system_default_accout 的系統預設帳號，但 $system_default_accout 帳號已停用且不具備LoginShell。"   >> $outfil
        else    
            echo "帳號 $system_default_accout 未停用。"  >> $outfil
        fi

    fi
done
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "2-10 系統預設帳號之適當性"  >> $outfil
echo "==================================" >> $outfil
echo "2-10-1 檢查帳號列表，是否留有guest帳號？"    >> $outfil
# 2. 列示廠商使用之帳號。
# 3. 列示所有系統帳號。
id guest >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "本系統有 GUEST 帳號。" >> $outfil
else
    echo "本系統無 GUEST 帳號。" >> $outfil
fi
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

echo "2-10-2 列示廠商使用之帳號。" >> $outfil
echo "==================================" >> $outfil
# getent passwd | awk -F: '$3 > 999 {print $1}'  >> $outfil
echo "同2-2檢查/etc/passwd"    >> $outfil
echo "本系統無廠商帳號"    >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

echo "2-10-3 列示所有系統帳號。" >> $outfil
echo "==================================" >> $outfil
getent passwd | awk -F: '$3 < 999 {print $1}' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "3-1 確認關閉telnet服務" >> $outfil
echo "==================================" >> $outfil
echo "check_services= telnet " >> $outfil

check_services=(telnet)

for service in ${check_services[@]}; do
    echo "檢查服務 $service 狀態"           >> $outfil
    cat /etc/services | grep "^$service "  >> $outfil
    service_enabled=$?

    cat /etc/services | grep "^#$service " >> $outfil
    service_disabled=$?

    if [ $service_enabled -eq 0 ]; then
        echo "$service 服務已啟動"          >> $outfil
    fi

    if [ $service_disabled -eq 0 ]; then
        echo "$service 服務已關閉"          >> $outfil
    fi

    if [ $service_disabled -gt 0 ] && [ $service_enabled -gt 0 ]; then
        echo "本系統無 $service 服務"       >> $outfil
    fi
    echo "----------------------------------" >> $outfil
    echo "  " >> $outfil
done
    echo "  " >> $outfil


echo "3-2 確認啟用SSH連線伺服器？" >> $outfil
echo "==================================" >> $outfil
echo "netstat -an |grep 22|grep LISTEN"  >> $outfil
netstat -an |grep :22|grep LISTEN  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "4-1 確認系統之稽核功能是否已經啟動？ "  >> $outfil
echo "==================================" >> $outfil
echo "4-1-1 ps -ef|grep audit |grep -v grep "  >> $outfil
ps -ef|grep audit |grep -v grep   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil
echo "4-1-2 cat auditd.conf |grep -v \"#\" "  >> $outfil
echo "==================================" >> $outfil
cat /etc/audit/auditd.conf |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "4-2 確認log file僅有root具有寫入權限。"  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /var/log/audit/audit.log "  >> $outfil
ls -l /var/log/audit/audit.log  >> $outfil

echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "5-1 確認cron設定之適當性,及crontab file /var/spool/cron/tabs 是否適當保護? "  >> $outfil
echo '5-1-1 crontab -l |grep -v "^#"'  >> $outfil
echo "==================================" >> $outfil
crontab -l |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo '5-1-2 cat /etc/cron.allow'  >> $outfil
echo "==================================" >> $outfil
cat /etc/cron.allow  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "6-1-1 確認作業系統是否已關閉不必要之網路服務\(inetd\) "  >> $outfil
echo "==================================" >> $outfil
# echo "/etc/xinetd.conf" >> $outfil
check_services=(finger ftp gopher imap  pop2 talk ntalk telnet uucp nfs nis)

for service in ${check_services[@]}; do
    echo "檢查服務 $service 狀態"           >> $outfil
    echo "cat /etc/services | grep "^${service} ""  >> $outfil
    cat /etc/services | grep "^$service "  >> $outfil
    service_enabled=$?

    cat /etc/services | grep "^#$service " >> $outfil
    service_disabled=$?

    if [ $service_enabled -eq 0 ]; then
        echo "$service 服務已啟動"          >> $outfil
    fi

    if [ $service_disabled -eq 0 ]; then
        echo "$service 服務已關閉"          >> $outfil
    fi

    if [ $service_disabled -gt 0 ] && [ $service_enabled -gt 0 ]; then
        echo "本系統未安裝 $service 服務"       >> $outfil
    fi
    echo "----------------------------------" >> $outfil
    echo "  " >> $outfil
done
    echo "  " >> $outfil


echo "6-1-2 確認只開啟必要之通訊埠及TCP/IP服務"  >> $outfil
echo "==================================" >> $outfil

if [ -f /etc/xinetd.d/telnet ]; then
    echo "本系統有安裝 telnet服務。"                      >> $outfil
else
    echo "本系統未安裝 telnet 服務，故無 telnet 設定檔。"  >> $outfil    
fi

echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "6-2 確認只開啟必要之通訊埠及TCP/IP服務"  >> $outfil
echo "==================================" >> $outfil
echo "檢查 /etc/xinetd.conf" >> $outfil
xinetd_services=(ftp telnet shell login exec talk ntalk imap pop2 pop3 finger auth)

for xinetd in ${xinetd_services[@]}; do
    echo "檢查服務 $xinetd 狀態" >> $outfil
    cat /etc/xinetd.d/$xinetd 2>/dev/null  | grep "service\|disable" >> $outfil
    if ! [ -f /etc/xinetd.d/$xinetd ]; then
        echo "本系統$xinetd服務已關閉，故未開啟$xinetd的通訊埠及TCP/IP服務" >> $outfil
        echo "  " >> $outfil
		fi
done
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

echo "7-1 確認目前是否已更新至修補程式之最適版本。 " >> $outfil
echo "==================================" >> $outfil
echo "維持半年前之最適版本"   >> $outfil
cat /etc/SuSE-release  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil

echo "8-1 確認是否執行系統弱點掃描。 "  >> $outfil
echo "==================================" >> $outfil
echo "資安科均定期執行弱點掃描"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "9-1 主機實體之鑰匙是否已妥善保管、使用？"  >> $outfil
echo "==================================" >> $outfil
echo "主機實體之鑰匙機房設簿登記管制"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil


echo "9-2 確認光碟機之使用係屬適當？"  >> $outfil
echo "==================================" >> $outfil
echo "安裝軟體、開申請單核准後進機房使用"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "  " >> $outfil
