#!/bin/bash
#
#
# compare_account.sh
# To compare user accounts of HACMP servers

diff_temp="$RANDOM"_temp
HCAMP_MAPPING_FILE="splunk_ping_map.txt"

create_today_serverlist() {
    find /source/opuse/*$(date +%Y%m%d)* -type f -name passwd |
        awk -F'/' '{print $4}' |
        awk -F'_' '{print $1}'
}

compare_user_of_this_server() {
    local _server=$1
    while read line; do
        echo "${line}" | grep -q -w $_server
        if [ $? -eq 0 ]; then
            _server_pair_left=$(echo $line | awk -F',' '{print $1}')
            _server_pair_right=$(echo $line | awk -F',' '{print $2}')

            if [ "${_server}" = "${_server_pair_left}" ]; then
                diff_etc_passwd_of_those_two_server \
                    $_server_pair_left $_server_pair_right
            fi
        fi
    done <$HCAMP_MAPPING_FILE
}

diff_etc_passwd_of_those_two_server() {
    local _server1=$1
    local _server2=$2
    diff_server1="$RANDOM"_temp
    diff_server2="$RANDOM"_temp

    sort /source/opuse/${_server1}_$(date +%Y%m%d)/passwd >$diff_server1
    sort /source/opuse/${_server2}_$(date +%Y%m%d)/passwd >$diff_server2
    diff $diff_server1 $diff_server2 >$diff_temp
    rc=$?

    if [ $rc -eq 0 ]; then
        echo "============================================="
        echo "UserAccounts in $_server1 and $_server2 are the same."
        return 0
    fi

    echo "============================================="
    echo "UserAccounts in $_server1 and $_server2 are NOT the same."
    awk -v _server1=$_server1 \
        -v _server2=$_server2 \
        -F':' \
        '/</{print _server2,"Do Not have account:", $1} \
         />/{print _server1, "Do Not have account:",$1}' $diff_temp
}

clear_up_temp() {
    rm $diff_server1
    rm $diff_server2
    rm $diff_temp
}

main() {
    server_list=$(create_today_serverlist)
    if [ -z "${server_list}" ]; then
        echo 'Fail to generate server list.'
        exit 1
    fi
    for server in $server_list; do
        compare_user_of_this_server $server
    done

    clear_up_temp
}
main
