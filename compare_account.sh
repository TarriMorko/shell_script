#!/bin/sh
#
#
# compare_account.sh
# To compare user accounts of HACMP servers

diff_temp="$RANDOM"_temp
arrange_temp="$RANDOM"_temp
HCAMP_MAPPING_FILE="splunk_ping_map.txt"
echo >compare_account_output

create_today_serverlist() {
  ls -l /source/opuse | grep -v total  | awk '{print $NF}' | awk -F'_' '{print $1}' | uniq | sort
}

compare_user_of_this_server() {
  local _server=$1
  while read line; do
    echo "${line}" | grep -q -w $_server
    if [ $? -eq 0 ]; then
      echo "DEBUG: line 21: LINE= $line"
      _server_pair_left=$(echo $line | awk -F',' '{print $1}')
      _server_pair_right=$(echo $line | awk -F',' '{print $2}')
      if [ "${_server}" = "${_server_pair_left}" ]; then
        echo "DEBUG: _server_pair_left=$_server_pair_left"
        echo "DEBUG: _server_pair_right=$_server_pair_right"
        diff_etc_passwd_of_those_two_server $_server_pair_left $_server_pair_right 
      fi
    fi
  done <$HCAMP_MAPPING_FILE
}

diff_etc_passwd_of_those_two_server() {
  local _server1=$1
  local _server2=$2
  server1_passwd="$RANDOM"_temp
  server2_passwd="$RANDOM"_temp
  diff_server1="$RANDOM"_temp
  diff_server2="$RANDOM"_temp

  echo "DEBUG: local server1=$_server1"
  echo "DEBUG: local server2=$_server2"

  passwd_location_of_server1=$(find /source/opuse/ -name "passwd" -type f | grep ${_server1} | sort | tail -n 1)
  echo "DEBUG: passwd_location_of_server1=$passwd_location_of_server1"
  if [ -z "${passwd_location_of_server1}" ]; then
    echo "DEBUG: can't find, using cat"

    server1_password_become_file=$(ls -ltr /source/opuse/ | grep -v ^d | grep $_server1 | awk '{print $NF}' | sort | tail -n 1)

    if [ -z "${server1_password_become_file}" ]; then
      echo "lost one of the passwd, compare $_server1, $_server2 terminate."
      return 1
    else
      cat /source/opuse/"${server1_password_become_file}"  >$server1_passwd
    fi

    echo "DEBUG: end of cat"
  else
    sort $passwd_location_of_server1 >$server1_passwd
  fi



  passwd_location_of_server2=$(find /source/opuse/ -name "passwd" -type f | grep ${_server2} | sort | tail -n 1)
  echo "DEBUG: passwd_location_of_server2=$passwd_location_of_server2"
  if [ -z "${passwd_location_of_server2}" ]; then
    echo "DEBUG: can't find, using cat"
    
    server2_password_become_file=$(ls -ltr /source/opuse/ | grep -v ^d | grep $_server2 | awk '{print $NF}' | sort | tail -n 1)
 
    if [ -z "${server2_password_become_file}" ]; then
      echo "lost one of the passwd, compare $_server1, $_server2 terminate."
      return 1
    else
      cat /source/opuse/"${server2_password_become_file}"  >$server2_passwd
    fi
    
    echo "DEBUG: end of cat"
  else
    sort $passwd_location_of_server2 >$server2_passwd
  fi

  
  #cat $server1_passwd
  echo "DEBUG: =================================================="
  

  cat $server1_passwd | awk -F':' '{print $1}' | sort >$diff_server1
  cat $server2_passwd | awk -F':' '{print $1}' | sort >$diff_server2



  echo "DEBUG: diff_server1=$diff_server1"
  echo "DEBUG: diff_server2=$diff_server2"

  diff $diff_server1 $diff_server2  >$diff_temp
  rc=$?

  if [ $rc -eq 0 ]; then
    echo "=============================================" >>compare_account_output
    echo "User Accounts in $_server1 and $_server2 are the same." >>compare_account_output
    return 0
  fi

  echo "=============================================" >>compare_account_output
  echo "User Accounts in $_server1 and $_server2 are NOT the same." >>compare_account_output
  awk -v _server1=$_server1 \
    -v _server2=$_server2 \
    -F':' \
    '/</{print _server2, "Do Not have account: ", $1} \
         />/{print _server1, "Do Not have account: ", $1}' $diff_temp >>compare_account_output
}


main() {
  server_list=$(create_today_serverlist)
#  echo "DEBUG: server_list=$server_list"
  if [ -z "${server_list}" ]; then
    echo 'Fail to generate server list.'
    exit 1
  fi
  for server in $server_list; do
    echo "DEBUG: compare_user_of_this_server: $server"
    echo "DEBUG: ===================================="
    compare_user_of_this_server $server
  done

  sed "s/<//" compare_account_output >${arrange_temp}
  sed "s/>//" ${arrange_temp} >compare_account_output
  cat compare_account_output
  echo
  rm -f *_temp

}

main

