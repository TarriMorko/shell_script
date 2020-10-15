#!/bin/ksh
#Run this shellscript everyday after eleven o'clock
#(DM will rotate at eleven o'clock)
#11 1 * * * /home/wasadmin/ArchiveTwnbWasLog.sh 1>/dev/null 2>&1

if [[ `whoami` == "root" ]];then
  su - wasadmin -c "/home/wasadmin/ArchiveWasLog.sh"
elif [[ `whoami` == "wasadmin" ]];then
    HOSTNAME=`hostname`

    case ${HOSTNAME} in
      twnbap1T)
        WorkDirs="/waslog9/cib_server1a_t/ /waslog9/nodeagent/"
        ;;
      twnbap2T)
        WorkDirs="/waslog9/cib_server2a_t/ /waslog9/nodeagent/ /waslog9/dmgr/"
        ;;
      *)
        echo "Make sure run this in the right server !!!"
        exit
        ;;
    esac

    LastCharacter=${HOSTNAME##${HOSTNAME%%?}}
    Today=`date +%y.%m.%d`
    Yesterday=`TZ=aaa24 date +%y.%m.%d`
    Weekday=`date +%A`

    #Production : Save the log for 30 Days
    #Staging and Develop : Save the log for 5 Days

    if [ "${LastCharacter}" == "P" ] ; then
      DaysToRemove=30
    else if [ "${LastCharacter}" == "T" ] ; then
      DaysToRemove=5
    else
      echo "Make sure run this in the right server !!!"
      exit
    fi
    fi

    for WorkDir in $WorkDirs
      do
      WAS=`echo $WorkDir | cut -d '/' -f 3`

      cd $WorkDir

      gzip SystemOut_$Yesterday*log
      gzip SystemErr_$Yesterday*log

      if [ "${Weekday}" == "Thursday" ] ; then
        cp -p native_stderr.log native_stderr.$Today.log
        gzip native_stderr.$Today.log
        > native_stderr.log
        cp native_stderr.$Today*gz $WorkDir/SFTP
      fi

      cp SystemOut_$Yesterday*gz /waslog9/SFTP/$WAS
      cp SystemErr_$Yesterday*gz /waslog9/SFTP/$WAS

      find $WorkDir -type f -mtime +$DaysToRemove -exec rm -f {} \;

    done

    cd /waslog9
    tar -cvf ./${HOSTNAME}_WASLOG9_${Yesterday}.tar SFTP
    mv ${HOSTNAME}_WASLOG9_${Yesterday}.tar SFTP

    ### sftp to ArcSight ###
    sftp spmqscp@10.0.7.104 <<EOF
cd WAS
put ./SFTP/*WASLOG9*.tar
exit
EOF
    
else
  echo "`whoami` ... Leave NOW !!!"
fi
