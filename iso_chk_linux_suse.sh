#!/bin/ksh
wrkdir=/home/spos2
hname=`hostname`
outfil=/home/spos2/$hname.iso_chk_linux.txt
echo "############################"  > $outfil
echo "# LINUX¨t²Î±j¤ÆÀË®Öªíªþ¥ó #" >> $outfil
echo "############################"  >> $outfil
echo "  " >> $outfil
echo  Hostname: $hname >> $outfil
echo "  " >> $outfil
echo "1-1 µn¿ýµe­±ªºwelcome message¬O§_§t¦³¨t²Î¸ê°T¡H" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/issue" >> $outfil
cat /etc/issue >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "cat /etc/issue.net" >> $outfil
cat /etc/issue.net >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

 
echo "2-1 ½T»{±K½X«~½è¨ÌºÞ²z­nÂI³]©w¡H" >> $outfil
echo "==================================" >> $outfil
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

echo "2-2 ½T»{¨Ï¥ÎŽÍ±b¸¹ªº¥i¿ë§O©Ê¡H" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/passwd "  >> $outfil
cat /etc/passwd   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-3½T»{root±b¸¹¤§ºÞ²z¬O§_¾A·í¡H " >> $outfil
echo "==================================" >> $outfil
echo "2-3-2 ½T»{/etc/passwd¤Î/etc/group¡Aroot¤§uid¤Îgid "  >> $outfil
echo "¦P 2-2 /etc/passwd ÀÉ" >> $outfil
echo "----------------------------------" >> $outfil
echo " cat /etc/group  "  >> $outfil
cat /etc/group   >> $outfil
echo "----------------------------------" >> $outfil

echo "2-3-3 ¦C¥X/etc/passwd¤Î/etc/group¤¤¡Auid¤Îgid¬°0ªº©Ò¦³¨Ï¥ÎŽÍ"  >> $outfil
cat /etc/passwd |grep ':0:0' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-4 ½T»{¤£¥²­n¨t²Î¹w³]±b¸¹¬O§_²¾°£©ÎÂê©w " >> $outfil
echo "==================================" >> $outfil
echo "2-4-1 ÀË¬d/etc/passwd±b¸¹¦Cªí¡A¬O§_¯d¦³guest±b¸¹¡H "  >> $outfil
echo "cat /etc/passwd |grep guest "  >> $outfil
cat /etc/passwd |grep guest   >> $outfil
echo "----------------------------------" >> $outfil

echo "2-4-2 ¦C¥Ü¼t°Ó¨Ï¥Î¤§±b¸¹ "  >> $outfil
echo "¦p2-2 /etc/passwd ÀÉ,µL¼t°Ó¨Ï¥Î¤§±b¸¹"  >> $outfil
echo "----------------------------------" >> $outfil

echo "2-4-3 ¦C¥Ü©Ò¦³¨t²Î¹w³]±b¸¹" >> $outfil
echo "cat /etc/passwd |awk 'FS=":"  {print $1,$3}'|awk '$2 < 200 {print $1}'"  >> $outfil
cat /etc/passwd |awk 'FS=":"  {print $1,$3}'|awk '$2 < 200 {print $1}'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-5 ¤@¯ë±b¸¹ºÞ²z" >> $outfil
echo "==================================" >> $outfil
echo "2-5-1,2 cat /etc/passwd "  >> $outfil
echo "¦P 2-2 /etc/passwd ÀÉ" >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-6 ½T»{±j­¢¨Ï¥ÎŽÍ¥¼§@¥ô¦ó°Ê§@¶W¹L¤@©w®É¶¡®É¡A¤©¥H±j­¢µn¥X¡H" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep LOGIN_TIMEOUT"  >> $outfil
cat /etc/login.defs |grep LOGIN_TIMEOUT >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil



echo "2-7 ½T»{¨t²Î¹w³]¨Ï¥ÎŽÍ±b¸¹ªºumask­È" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep UMASK |grep 027"  >> $outfil
cat /etc/login.defs |grep UMASK |grep 027 >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-8 ÀË¬drootµn¤J®É¬O§_°õ¦æ«Drootªºµ{¦¡?"  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /root/.profile" >> $outfil
ls -l /root/.profile >> $outfil
cat /root/.profile  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-9 ½T»{¬O§_Ãö³¬¤£¥²»Ý­nµn¤JÅv­­ªº¨t²Î¹w³]±b¸¹"  >> $outfil
echo "==================================" >> $outfil

# ½T»{adm, bin, daemon, listen, lp, nobody, noaccess, nuucp, smtp, sys, uucpµ¥±b¸¹¬Ò¤w°±¥Î¥B¤£¨ã³Ælogin shell¡C
system_default_accouts=(adm bin daemon listen lp nobody noaccess nuucp smtp sys uucp)
for system_default_accout in ${system_default_accouts[@]}; do
    login_sh=$(awk -v S=$system_default_accout -F':' '$1 == S {print $NF}' /etc/passwd)
    if [[ -z "$login_sh" ]]; then
        echo "¥»¨t²ÎµL $system_default_accout ±b¸¹¡C"  >> $outfil
    else
        if 	[ "$login_sh" == "/bin/false" ]; then
            echo "¥»¨t²Î¦³ $system_default_accout ªº¨t²Î¹w³]±b¸¹¡A¦ý $system_default_accout  ±b¸¹¤w°±¥Î¥B¤£¨ã³Ælogin shell¡C"   >> $outfil
        else    
            echo "±b¸¹ $system_default_accout ¥¼°±¥Î¡C"  >> $outfil
        fi

    fi
done

echo "2-10 ¨t²Î¹w³]±b¸¹¤§¾A·í©Ê"  >> $outfil
echo "==================================" >> $outfil
# 1. ÀË¬d±b¸¹¦Cªí¡A¬O§_¯d¦³guest±b¸¹¡H
# 2. ¦C¥Ü¼t°Ó¨Ï¥Î¤§±b¸¹¡C
# 3. ¦C¥Ü©Ò¦³¨t²Î±b¸¹¡C


id guest >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "¥»¨t²Î¦³ GUEST ±b¸¹¡C" >> $outfil
else
    echo "¥»¨t²ÎµL GUEST ±b¸¹¡C" >> $outfil
fi

echo "==================================" >> $outfil
echo "¦C¥Ü¼t°Ó¨Ï¥Î¤§±b¸¹¡C" >> $outfil
getent passwd | awk -F: '$3 > 999 {print $1}'

echo "==================================" >> $outfil
echo "¦C¥Ü©Ò¦³¨t²Î±b¸¹¡C" >> $outfil
getent passwd | awk -F: '$3 < 999 {print $1}' >> $outfil




echo "3-1 ½T»{Ãö³¬telnetªA°È" >> $outfil
echo "==================================" >> $outfil
echo "netstat -an |grepa :23 |grep LISTEN" >> $outfil
netstat -an |grep :23|grep LISTEN  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "3-2 ½T»{±Ò¥ÎSSH³s½u¦øªA¾¹¡H" >> $outfil
echo "==================================" >> $outfil
echo "netstat -an |grep 22|grep LISTEN"  >> $outfil
netstat -an |grep :22|grep LISTEN  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-1 ½T»{¨t²Î¤§½]®Ö¥\¯à¬O§_¤w¸g±Ò°Ê¡H "  >> $outfil
echo "==================================" >> $outfil
echo "4-1-1 ps -ef|grep audit |grep -v grep "  >> $outfil
ps -ef|grep audit |grep -v grep   >> $outfil
echo "----------------------------------" >> $outfil
echo "4-1-2 cat auditd.conf |grep -v "#" "  >> $outfil
cat /etc/audit/auditd.conf |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-2 ½T»{log file¶È¦³root¨ã¦³¼g¤JÅv­­¡C"  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /var/log/audit/audit.log "  >> $outfil
ls -l /var/log/audit/audit.log  >> $outfil

echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "5-1 ½T»{cron³]©w¤§¾A·í©Ê,¤Îcrontab file(/var/spool/cron/tabs)¬O§_¾A·í«OÅ@? "  >> $outfil
echo "==================================" >> $outfil
echo '5-1-1 crontab -l |grep -v "^#"'  >> $outfil
crontab -l |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo '5-1-2 cat /etc/cron.allow'  >> $outfil
cat /etc/cron.allow  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-1 ½T»{§@·~¨t²Î¬O§_¤wÃö³¬¤£¥²­n¤§ºô¸ôªA°È(inetd) "  >> $outfil
echo "==================================" >> $outfil


check_services=(finger ftp gopher imap  pop2 talk ntalk telnet uucp nfs nis)

for service in ${check_services[@]}; do
    echo "ÀË¬dªA°È $service ª¬ºA"           >> $outfil
    cat /etc/services | grep "^$service "  >> $outfil
    service_enabled=$?

    cat /etc/services | grep "^#$service " >> $outfil
    service_disabled=$?

    if [ $service_enabled -eq 0 ]; then
        echo "$service ªA°È¤w±Ò°Ê"          >> $outfil
    fi

    if [ $service_disabled -eq 0 ]; then
        echo "$service ªA°È¤wÃö³¬"          >> $outfil
    fi

    if [ $service_disabled -gt 0 ] && [ $service_enabled -gt 0 ]; then
        echo "¥»¨t²ÎµL $service ªA°È"       >> $outfil
    fi
    echo "----------------------------------" >> $outfil
done


echo "6-2 ½T»{¥u¶}±Ò¥²­n¤§³q°T°ð¤ÎTCP/IPªA°È"  >> $outfil
echo "==================================" >> $outfil
xinetd_services=(ftp vnc telnet shell login exec talk ntalk imap pop2 pop3 finger auth)

for xinetd in ${xinetd_services[@]}; do
    echo "ÀË¬dªA°È $xinetd ª¬ºA" >> $outfil
    cat /etc/xinetd.d/$xinetd 2>/dev/null  | grep "service\|disable" >> $outfil
    if ! [ -f /etc/xinetd.d/$xinetd ]; then
        echo "¥»¨t²Î¥¼¦w¸Ë $xinetd ªA°È" >> $outfil
    fi
done


echo "7-1 ½T»{¥Ø«e¬O§_¤w§ó·s¦Ü­×¸Éµ{¦¡¤§³Ì¾Aª©¥»¡C " >> $outfil
echo "==================================" >> $outfil
echo "ºû«ù¥b¦~«e¤§³Ì¾Aª©¥»"   >> $outfil
sam --no-header-sig-check --no-rpm-verify --no-rpm-verify-md5 --skip-unmatched-prod --strict-repo-description --no-log-timestamp |grep name:|awk '{print $2}'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "8-1 ½T»{¬O§_°õ¦æ¨t²Î®zÂI±½´y¡C "  >> $outfil
echo "==================================" >> $outfil
echo "¸ê¦w¬ì§¡©w´Á°õ¦æ®zÂI±½´y"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "9-1 ¥D¾÷¹êÅé¤§Æ_°Í¬O§_¤w§´µ½«OºÞ¡B¨Ï¥Î¡H"  >> $outfil
echo "==================================" >> $outfil
echo "¥D¾÷¹êÅé¤§Æ_°Í¾÷©Ð³]Ã¯µn°OºÞ¨î"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "9-2 ½T»{¥úºÐ¾÷¤§¨Ï¥Î«YÄÝ¾A·í¡H"  >> $outfil
echo "==================================" >> $outfil
echo "¦w¸Ë³nÅé¡B¶}¥Ó½Ð³æ®Ö­ã«á¶i¾÷©Ð¨Ï¥Î"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
