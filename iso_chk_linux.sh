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

echo "2-2 ½T»{¨Ï¥ÎªÌ±b¸¹ªº¥i§P§O©Ê¡H" >> $outfil
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

echo "2-3-3 ¦C¥X/etc/passwd¤Î/etc/group¤¤¡Auid¤Îgid¬°0ªº©Ò¦³¨Ï¥ÎªÌ"  >> $outfil
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

echo "2-6 ½T»{±j­¢¨Ï¥ÎªÌ¥¼§@¥ô¦ó°Ê§@¶W¹L¤@©w®É¶¡®É¡A¤©¥H±j­¢µn¥X¡H" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep LOGIN_TIMEOUT"  >> $outfil
cat /etc/login.defs |grep LOGIN_TIMEOUT >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil



echo "2-7 ½T»{¨t²Î¹w³]¨Ï¥ÎªÌ±b¸¹ªºumask­È¬°027¬" >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/login.defs |grep UMASK |grep 027"  >> $outfil
cat /etc/login.defs |grep UMASK |grep 027 >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-8 ÀË¬drootµn¤J®É¬O§_°õ¦æ«Drootªºµ{¦¡­"  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /root/.profile" >> $outfil
ls -l /root/.profile >> $outfil
cat /root/.profile  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-9 ½T»{¬O§_Ãö³¬¤£¥²»Ý­nµn¤JÅv­­ªº¨t²Î¹w³]±b¸¹­"  >> $outfil
echo "==================================" >> $outfil
echo "¦P 2-2 /etc/passwd ÀÉ" >> $outfil
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


echo "4-2 ½T»{¨t²Î½]®ÖlogÀÉ¬O§_¾A·í«OÅ@¡H "  >> $outfil
echo "==================================" >> $outfil
echo "ls -l /var/log/audit/audit.log "  >> $outfil
ls -l /var/log/audit/audit.log   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "5-1 ½T»{cron³]©w¤§¾A·í©Ê,¤Îcrontab file(/var/spool/cron/tabs)¬O§_¾A·í«OÅ@Å "  >> $outfil
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

echo "6-2 ½T»{¥u¶}±Ò¥²­n¤§³q°T°ð¤ÎTCP/IPªA°È"  >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/xinetd.conf |grep -v "^#""  >> $outfil
cat /etc/xinetd.conf |grep -v "^#"  >> $outfil
echo "----------------------------------" >> $outfil
echo "chkconfig --list |tail -18 "  >> $outfil
chkconfig --list |tail -18   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


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
