#!/bin/sh
# date : 2020-09-15
# line  #34  #78  #45:${ACCESS_REPORT}
#
# 建置帳號對程式及資料檔案相關權限之檢查功能介面，於帳號清查作業時一併列示清查
# 使用前請先定義 以下參數
# skip_check    # 如果設定不是 "n" 則跳過檢查
# DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION  #掃描這些目錄下所有檔案與目錄的權限

rm -f ${0%/*}/*.temp

skip_check="n"
DIRECTORY_YOU_WANT_TO_CHECK="/tmp /tmp/bin /none1 /source"
_DIR=$DIRECTORY_YOU_WANT_TO_CHECK
direct_option="direct"
option_1="$1"
_HOME="/src/chkau/report"
[ -d "${_HOME}" ] || mkdir -p ${_HOME}
dc01_home="/home/dc01"
[ -d "${dc01_home}" ] || mkdir -p ${dc01_home}
dc01_REPORT="${dc01_home}/ACCESS_report_$(hostname)_$(date +%Y%m%d).txt"
ACCESS_REPORT="${_HOME}/ACCESS_report_$(hostname)_$(date +%Y%m%d).txt"
typeset -i x
typeset -i c1
typeset -i c2
typeset -i wc_

if [[ "$(uname)" = "Linux" ]]; then
  OS="Linux"
else
  OS="AIX"
fi

#OS="AIX"

show_main_menu() {
  # Just show main menu.
  clear
  cat <<EOF
  +====================================================================+
       非系統帳號對業務程式及資料檔案之相關權限查詢
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 執行帳號權限檢查。將結果寫入 ${dc01_REPORT}
      2. 列出執行結果

      q.QUIT

EOF
}

list_dirs_permissions_by_user() {
  # example
  # 
  # spos2    read       exec /home

  False=1
  True=0
  ONE_OF_DIRECTORY_HAS_RWX_PERMISSION=$False

  cat /dev/null > ${ACCESS_REPORT}
  check_t=""

  if [ "${skip_check}" != "n" ] ; then
    skip_check_y
    if [ "${option_1}" != "${direct_option}" ] ; then
      cp_report
    fi
    return
  fi

  if [[ "$OS" = "Linux" ]]; then
    ids=$(grep "^AllowUsers" /etc/ssh/sshd_config | tr ' ' '\n' | grep -v '@' | grep -v AllowUsers )
  else

    ex_ids=$(grep "^AllowUsers" /etc/ssh/sshd_config | tr ' ' '\n' | grep '@' | awk -F@ '{print $1}' | sort | uniq)

    tmp_ids1=${0%/*}/tmp_ids1.${RANDOM}.temp
    tmp_ids2=${0%/*}/tmp_ids2.${RANDOM}.temp
    lsuser ALL 2> /dev/null | grep rlogin=true | awk '{print $1}' > ${tmp_ids1}
    #cat /src/chkau/reference/lsuser_ALL_permission | grep rlogin=true | awk '{print $1}' > ${tmp_ids1}

    for i in ${ex_ids} ; do
      grep -v ${i} ${tmp_ids1} > ${tmp_ids2}
      cat ${tmp_ids2} > ${tmp_ids1}
    done
    ids=$(cat ${tmp_ids1})
    rm -f ${tmp_ids1} ${tmp_ids2}

  fi

  if [[ -z "${ids}" ]]; then
    ids=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')
  fi

  if [ "${option_1}" != "${direct_option}" ] ; then
    echo "Please wait..."
  fi

  echo "                                 使用者對重要系統伺服器重要業務檔案與程式權限清查" >>${ACCESS_REPORT}
  echo '' >>${ACCESS_REPORT}
  echo HOSTNAME: $(hostname) "    " TIME: $(date +%Y/%m/%d) $(date +%H:%M:%S) >>${ACCESS_REPORT}
  echo "" >>${ACCESS_REPORT}

  check_1=0
  for i in ${DIRECTORY_YOU_WANT_TO_CHECK} ; do
    if [ -d "${i}" ] ; then
       check_t="${check_t} ${i}"
    else
       echo "${i} 不存在！  請確認 DIRECTORY_YOU_WANT_TOCHECK 設定值" >>${ACCESS_REPORT}
    fi
  done

  DIRECTORY_YOU_WANT_TO_CHECK="${check_t}"

  check_box="口續用口不續用，將開單刪除"
  step_n=28

  for id in ${ids} ; do
    table_head="0"
    for _dir in ${DIRECTORY_YOU_WANT_TO_CHECK} ; do
      _readable=""
      _writable=""
      _execable=""
      su ${id} -c "test -r '${_dir}'" >/dev/null 2>&1 && _readable="read"
      su ${id} -c "test -w '${_dir}'" >/dev/null 2>&1 && _writable="write"
      su ${id} -c "test -x '${_dir}'" >/dev/null 2>&1 && _execable="exec"

      if ! [[ "${_readable}" = "" && "${_writable}" = "" && "${_execable}" = "" ]]; then
        ONE_OF_DIRECTORY_HAS_RWX_PERMISSION=$True

        if [ ${table_head} == "0" ] ; then
          echo '' >>${ACCESS_REPORT}
          echo "  帳號     讀取    寫入  執行        檔案或程式路徑                  負責科別    持有人簽章   續用/不續用，將開單刪除" >>$ACCESS_REPORT
          table_head="1"
        fi
	    echo '======================================================================================================================' >> ${ACCESS_REPORT}

        if [ ${id} == "cbrusr" ] || [ $(echo ${id} | cut -c1-2) == "sp" ] ||   [ $(echo ${id} | cut -c1-2) == "op" ] ; then
          Branch="  系統管理科"
        elif [ $(echo ${id} | cut -c1-2) == "dc" ] ; then
          Branch="  資料管制科"
        else
          Branch=""
        fi

        wc_t=$(echo ${_dir} | wc -m | awk '{print $1}')
        wc_=$((${wc_t}-1))
        x=0
        c1=1
        while [ "${wc_}" -gt "${x}" ] ; do

          c2=$((${c1}+${step_n}))
          if [ ${c2} -gt ${wc_}  ] ; then
            c2=${wc_}
          fi
          if [ ${c1} -gt ${c2} ] ; then
            break
          fi

          sub_chr=$(echo ${_dir} | cut -c${c1}-${c2})
          c1=$((${c2}+1))

          if [ "${x}" -eq 0 ] ; then
            printf "%-10s %-7s %-5s %-10s %-29s %-12s %-12s %-s \n" "${id}" "${_readable}" "${_writable}" "${_execable}" "${sub_chr}" "${Branch}" "" "${check_box}" >>${ACCESS_REPORT}
          else
            printf "%-35s %-s \n" " " "${sub_chr}" >>${ACCESS_REPORT}
          fi
          x=$((${x}+${step_n}))
        done
        echo '' >>${ACCESS_REPORT}

      #else

        #x=0
        #wc_=${#_dir}
        #while [ "${wc_}" -gt "${x}" ] ; do
        #  if [[ "$OS" = "Linux" ]]; then
        #    sub_chr=${_dir:${x}:${step_n}}
        #  else
        #    sub_chr=$(echo ${_dir} | cut -c${x}-${step_n})
        #  fi
        #  if [ "${x}" -eq 0 ] ; then
        #    printf "%-10s %-27s %-29s \n" ${id} "無 read write exec 權限" "${sub_chr}" >>${ACCESS_REPORT}
        #  else
        #    printf "%-35s %-s \n" " " "${sub_chr}" >>${ACCESS_REPORT}
        #  fi
        #  x=${x}+${step_n}
        #done

      fi

      #sub_dirs=$(ls -la ${_dir} | grep "^d" | awk '{print $NF}' | grep -v "^\.")
      #for sub_dir in $sub_dirs; do
      #  _readable=""
      #  _writable=""
      #  _execable=""
      #  su ${id} -c "test -r '${_dir}/$sub_dir'" >/dev/null 2>&1 && _readable="read"
      #  su ${id} -c "test -w '${_dir}/$sub_dir'" >/dev/null 2>&1 && _writable="write"
      #  su ${id} -c "test -x '${_dir}/$sub_dir'" >/dev/null 2>&1 && _execable="exec"
      #  if ! [[ "${_readable}" = "" && "${_writable}" = "" && "${_execable}" = "" ]]; then

      #    x=0
      #    _dir2="${_dir}/$sub_dir"
      #    wc_=${#_dir2}
      #    while [ "${wc_}" -gt "${x}" ] ; do
      #      if [[ "$OS" = "Linux" ]]; then
      #        sub_chr=${_dir2:${x}:${step_n}}
      #      else
      #        sub_chr=$(echo ${_dir2} | cut -c${x}-${step_n})
      #      fi
      #      if [ "${x}" -eq 0 ] ; then
      #        printf "%-10s %-7s %-5s %-10s %-29s %-s \n" ${id} "${_readable}" "${_writable}" "${_execable}" "${sub_chr}" "${check_box}" >>${ACCESS_REPORT}
      #      else
      #        printf "%-35s %-s \n" " " "${sub_chr}" >>${ACCESS_REPORT}
      #      fi
      #      x=${x}+${step_n}
      #    done

      #  fi
      #done
    done
  done

  if [ $ONE_OF_DIRECTORY_HAS_RWX_PERMISSION -eq 0 ];then
    echo ""
  else
    echo "本伺服器可遠端帳號皆無權限存取以下路徑 $_DIR"  >>${ACCESS_REPORT} 
  fi

  if [ "${option_1}" != "${direct_option}" ] ; then
    cp_report
  fi


}


list_last_ACCESS_REPORT() {
  if [ -f "${ACCESS_REPORT}" ]; then
    cat ${ACCESS_REPORT}
    return
  else
    echo "沒有今天的報告。"
    return
  fi

  reports=$(ls -tr ACCESS_*)

  if [ -z "${reports}" ]; then
    echo "未產生過報告，請執行選項 1。"
    return
  fi

  last_report=$(ls -tr ACCESS_* | tail -1)
  cat ${last_report}

}


skip_check_y() {
  echo "                                 使用者對重要系統伺服器重要業務檔案與程式權限清查" >>${ACCESS_REPORT}
  echo '' >>${ACCESS_REPORT}
  echo HOSTNAME: $(hostname) "    " TIME: $(date +%Y/%m/%d) $(date +%H:%M:%S) >>${ACCESS_REPORT}
  echo '' >>${ACCESS_REPORT}
  echo "本伺服器無重要業務檔案路徑" >>${ACCESS_REPORT}
  echo '' >>${ACCESS_REPORT}
}


cp_report() {
  \cp -f ${ACCESS_REPORT} ${dc01_REPORT}
  chown dc01 ${dc01_REPORT}
  chmod 770 ${dc01_REPORT}
}


main() {
  # The entry for sub functions.
  while true; do
    cd ${_HOME}
    show_main_menu
    read choice
    clear
    case ${choice} in
    1) list_dirs_permissions_by_user ;;
    2) list_last_ACCESS_REPORT ;;
    [Qq])
      echo ''
      echo 'Thanks !! bye bye ^-^ !!!'
      echo ''
      exit
      logout
      ;;
    *)
      clear
      echo ''
      echo ' !!!  ERROR CHOICE , PRESS ENTER TO CONTINUE ... !!!'
      read choice
      ;;
    esac
    echo ''
    echo 'Press enter to continue' && read null
  done
}

if [ "${option_1}" != "${direct_option}" ] ; then
  main
else
  list_dirs_permissions_by_user
fi

rm -f ${0%/*}/*.temp

exit 0

