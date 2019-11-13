#!/bin/ksh

#21 1 * * * /home/ihsadmin/ArchiveFtpMobileIhsLog.sh 1>/dev/null 2>&1

if [[ $(whoami) == "root" ]]; then
  su - ihsadmin -c "/home/ihsadmin/ArchiveFtpMobileIhsLog.sh"
elif [[ $(whoami) == "ihsadmin" ]]; then
  HOSTNAME=$(hostname)
  LastCharacter=${HOSTNAME##${HOSTNAME%%?}}
  Today=$(date +%y.%m.%d)
  Yesterday=$(TZ=aaa24 date +%y.%m.%d)

  ###    Weekday=`date +%A`
  #Production : Save the log for 30 Days
  #Staging and Develop : Save the log for 5 Days

  if [ "${LastCharacter}" == "P" ]; then
    DaysToRemove=30
  else
    if [ "${LastCharacter}" == "T" ]; then
      DaysToRemove=5
    else
      echo "Make sure run this in the right server !!!"
      exit
    fi
  fi

  rm -Rf /ihslog/FTP/*
  mkdir /ihslog/FTP/$WAS
  cd /ihslog

function rotate_file
{
  
}
  oldfile="http_plugin.log"
  newfile=${oldfile}.${Yesterday}
  cp -p $oldfile $newfile
  gzip $newfile
  >$oldfile

  oldfile="error_log"
  newfile=${oldfile}.${Yesterday}
  cp -p $oldfile $newfile
  gzip $newfile
  >$oldfile

  oldfile="ssl_error.log"
  newfile=${oldfile}.${Yesterday}
  cp -p $oldfile $newfile
  gzip $newfile
  >$oldfile

  oldfile="access_log"
  newfile=${oldfile}.${Yesterday}
  cp -p $oldfile $newfile
  gzip $newfile
  >$oldfile

  oldfile="ssl_access.log"
  newfile=${oldfile}.${Yesterday}
  cp -p $oldfile $newfile
  gzip $newfile
  >$oldfile

  cp *${Yesterday}*gz /ihslog/FTP
  find /ihslog -type f -mtime +$DaysToRemove -exec rm -f {} \;
  cd /ihslog
  tar -cvf ./${HOSTNAME}_IHSLOG_${Yesterday}.tar FTP
  mv ${HOSTNAME}_IHSLOG_${Yesterday}.tar FTP

  ###    ftp -inv < /home/ihsadmin/ftp.cfg > /home/ihsadmin/ftp.out

  /home/ihsadmin/ftp_used.sh >/home/ihsadmin/temp.ftp.cfg
  ftp -inv </home/ihsadmin/temp.ftp.cfg >/home/ihsadmin/ftp.out
  rm /home/ihsadmin/temp.ftp.cfg

else
  echo "$(whoami) ... Leave NOW !!!"
fi
