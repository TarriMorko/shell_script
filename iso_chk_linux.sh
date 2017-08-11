#!/bin/sh
#
#

if ! [ -f /etc/redhat-release ]; then
    echo "This script is for redhat ONLY."
    exit 0
fi

wrkdir=/home/spos2
hname=`hostname`
outfil=/home/spos2/$hname.iso_chk_linux.txt
echo "############################"  > $outfil
echo "# LINUX系統強化檢核表附件 #" >> $outfil
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

 
echo "2-1 確認密碼品質依管理要點設定？" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/login.defs|grep PASS_MAX_DAYS"  >> $outfil
cat /etc/login.defs|grep PASS_MAX_DAYS |grep -v "^#" >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "grep -R "crack" --color" >> $outfil
grep -R "crack" --color >> $outfil

echo "----------------------------------" >> $outfil
# echo "pam-config -q --pwhistory ">> $outfil
# pam-config -q --pwhistory >> $outfil

echo "egrep -i -o remember=[0-9]  /etc/pam.d/system-auth">> $outfil # 新加的
egrep -i -o remember=[0-9] /etc/pam.d/system-auth >> $outfil        # 新加的

echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-2 確認使用者帳號的可判別性？" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/passwd "  >> $outfil
cat /etc/passwd   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-3確認root帳號之管理是否適當？ " >> $outfil
echo "==================================" >> $outfil
echo "2-3-2 確認/etc/passwd及/etc/group，root之uid及gid "  >> $outfil
echo "同 2-2 /etc/passwd 檔" >> $outfil
echo "----------------------------------" >> $outfil
echo " cat /etc/group  "  >> $outfil
cat /etc/group   >> $outfil
echo "----------------------------------" >> $outfil

echo "2-3-3 列出/etc/passwd及/etc/group中，uid及gid為0的所有使用者"  >> $outfil
cat /etc/passwd |grep ':0:0' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-4 確認不必要系統預設帳號是否移除或鎖定 " >> $outfil
echo "==================================" >> $outfil
echo "2-4-1 檢查/etc/passwd帳號列表，是否留有guest帳號？ "  >> $outfil
echo "cat /etc/passwd |grep guest "  >> $outfil
cat /etc/passwd |grep guest   >> $outfil
echo "----------------------------------" >> $outfil

echo "2-4-2 列示廠商使用之帳號 "  >> $outfil
echo "如2-2 /etc/passwd 檔,無廠商使用之帳號"  >> $outfil
echo "----------------------------------" >> $outfil

echo "2-4-3 列示所有系統預設帳號" >> $outfil
echo "cat /etc/passwd |awk 'FS=":"  {print $1,$3}'|awk '$2 < 200 {print $1}'"  >> $outfil
cat /etc/passwd |awk 'FS=":"  {print $1,$3}'|awk '$2 < 200 {print $1}'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-5 一般帳號管理" >> $outfil
echo "==================================" >> $outfil
echo "2-5-1,2 cat /etc/passwd "  >> $outfil
echo "同 2-2 /etc/passwd 檔" >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-6 確認強迫使用者未作任何動作超過一定時間時，予以強迫登出？" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/profile |grep TMOUT"  >> $outfil
cat /etc/profile |grep TMOUT >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil



echo "2-7 確認系統預設使用者帳號的umask值為027?" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep UMASK |grep 027"  >> $outfil
cat /etc/login.defs |grep UMASK |grep 027 >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-8 檢查root登入時是否執行非root的程式?"  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /root/.profile" >> $outfil
ls -l /root/.profile >> $outfil
cat /root/.profile  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-9 確認是否關閉不必需要登入權限的系統預設帳號?"  >> $outfil
echo "==================================" >> $outfil
echo "同 2-2 /etc/passwd 檔" >> $outfil
cat /etc/passwd |grep adm:x |grep -v itmadm >> $outfil
cat /etc/passwd |grep bin:x >> $outfil
cat /etc/passwd |grep daemon:x >> $outfil
cat /etc/passwd |grep listen >> $outfil
cat /etc/passwd |grep lp >> $outfil
cat /etc/passwd |grep nobody >> $outfil
cat /etc/passwd |grep noaccess >> $outfil
cat /etc/passwd |grep nuucp >> $outfil
cat /etc/passwd |grep stmtp >> $outfil
cat /etc/passwd |grep sys:x >> $outfil
cat /etc/passwd |grep uucp >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "3-1 確認關閉telnet服務" >> $outfil
echo "==================================" >> $outfil
echo "netstat -an |grepa :23 |grep LISTEN" >> $outfil
netstat -an |grep :23|grep LISTEN  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "3-2 確認啟用SSH連線伺服器？" >> $outfil
echo "==================================" >> $outfil
echo "netstat -an |grep 22|grep LISTEN"  >> $outfil
netstat -an |grep :22|grep LISTEN  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-1 確認系統之稽核功能是否已經啟動？ "  >> $outfil
echo "==================================" >> $outfil
echo "4-1-1 ps -ef|grep audit |grep -v grep "  >> $outfil
ps -ef|grep audit |grep -v grep   >> $outfil
echo "----------------------------------" >> $outfil
echo "4-1-2 cat auditd.conf |grep -v "#" "  >> $outfil
cat /etc/audit/auditd.conf |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-2 確認系統稽核log檔是否適當保護？ "  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /var/log/audit/audit.log "  >> $outfil
ls -l /var/log/audit/audit.log   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "5-1 確認cron設定之適當性,及crontab file(/var/spool/cron/tabs)是否適當保護? "  >> $outfil
echo "==================================" >> $outfil
echo '5-1-1 crontab -l |grep -v "^#"'  >> $outfil
crontab -l |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo '5-1-2 cat /etc/cron.allow'  >> $outfil
cat /etc/cron.allow  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-1 確認作業系統是否已關閉不必要之網路服務(inetd) "  >> $outfil
echo "==================================" >> $outfil
cat /etc/services |grep finger >> $outfil
cat /etc/services |grep ftp|grep " 21/"  >> $outfil
cat /etc/services |grep gopher >> $outfil
cat /etc/services |grep imap |grep "143/" >> $outfil
cat /etc/services |grep pop2 >> $outfil
cat /etc/services |grep talk |grep "517/" >> $outfil
cat /etc/services |grep talk |grep "518/" >> $outfil
cat /etc/services |grep telnet |grep " 23/" >> $outfil
cat /etc/services |grep uucp |grep "540/" >> $outfil
cat /etc/services |grep nfs |grep "2049/" >> $outfil
cat /etc/services |grep "nis   "|grep "/tcp"|grep "/udp" >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-2 確認只開啟必要之通訊埠及TCP/IP服務"  >> $outfil
echo "==================================" >> $outfil
# echo "cat /etc/xinetd.conf |grep -v "^#""  >> $outfil
# cat /etc/xinetd.conf |grep -v "^#"  >> $outfil
# echo "----------------------------------" >> $outfil
echo "chkconfig --list  "  >> $outfil
chkconfig --list    >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


# 找不到
echo "7-1 確認目前是否已更新至修補程式之最適版本。 " >> $outfil
echo "==================================" >> $outfil
echo "維持半年前之最適版本"   >> $outfil
# sam --no-header-sig-check --no-rpm-verify --no-rpm-verify-md5 --skip-unmatched-prod --strict-repo-description --no-log-timestamp |grep name:|awk '{print $2}'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "8-1 確認是否執行系統弱點掃描。 "  >> $outfil
echo "==================================" >> $outfil
echo "資安科均定期執行弱點掃描"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "9-1 主機實體之鑰匙是否已妥善保管、使用？"  >> $outfil
echo "==================================" >> $outfil
echo "主機實體之鑰匙機房設簿登記管制"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "9-2 確認光碟機之使用係屬適當？"  >> $outfil
echo "==================================" >> $outfil
echo "安裝軟體、開申請單核准後進機房使用"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
