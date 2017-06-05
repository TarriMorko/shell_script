#!/bin/bash
cp -p /etc/issue /etc/issue.bak
cp -p /etc/issue.net  /etc/issue.net.bak
cp -p /etc/login.defs  /etc/login.defs.bak
cp -p /etc/pam.d/common-password-pc /etc/pam.d/common-password-pc.bak
cp -p /etc/pam.d/common-auth-pc /etc/pam.d/common-auth-pc.bak
cp -p /etc/pam.d/common-account-pc /etc/pam.d/common-account-pc.bak
cp -p /etc/passwd /etc/passwd.bak
cp -p /etc/audit/audit.rules /etc/audit/audit.rules.bak
cp -p /etc/audit/auditd.conf /etc/audit/auditd.conf.bak
cp -p /etc/profile.local /etc/profile.local.bak
cp -p /etc/profile /etc/profile.bak
cp -p /etc/cron.allow /etc/cron.allow.bak
cp -p /etc/services /etc/services.bak
cp -p /etc/security/pam_pwcheck.conf /etc/security/pam_pwcheck.conf.bak
cp -p /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf.bak
#############
sed s/bash/false/g /etc/passwd | grep -v root  > /etc/passwd.tmp
cat /etc/passwd | grep root >> /etc/passwd.tmp
cat /etc/passwd.tmp > /etc/passwd
rm /etc/passwd.tmp
##############
tar -xvpPf /tmp/tar_iso.tar

/etc/rc.d/sshd  restart
/etc/rc.d/syslog restart

mkdir /aulog/audreport
chmod -R 700 /aulog/audreport

faillog -m 5 -u spos1
faillog -m 5 -u spos2
faillog -m 5 -u spos3
faillog -m 5 -u dc01
faillog -m 5 -u dcporting
faillog -m 5 -u spadmin
