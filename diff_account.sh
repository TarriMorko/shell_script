#!/bin/ksh
#
#
remote_user="opusr"
HA_list="host_list_HA.txt"
temp1="$RANDOM"_temp
temp2="$RANDOM"_temp
diff_temp="$RANDOM"_temp
HA_server_name_and_ip="HA_server_name_and_ip.txt"

create_mapping() {
    # Change the host name in host_list_HA to IP address.
    #
    # Use the IP addr in host_list_22.txt, then create a new TXT file.
    # this files must in unix text format.

    echo "# Create at "$(date +%Y%m%d_%H%M%S) >$HA_server_name_and_ip

    while read line; do
        echo "$line" | grep -q "^.*#"
        if [ $? -eq 0 ]; then continue; fi

        server1=$(echo $line | cut -d',' -f1)
        server2=$(echo $line | cut -d',' -f2)
        #echo $server1, $server2 # DEBUG

        ip_1=$(grep $server1 host_list_22.txt | head -n 1 | awk '{print $2}')
        if [ "${ip_1}" == "" ]; then continue; fi

        ip_2=$(grep $server2 host_list_22.txt | head -n 1 | awk '{print $2}')
        if [ "${ip_2}" == "" ]; then continue; fi

        echo $server1,$ip_1,$server2,$ip_2 >>$HA_server_name_and_ip

    done <$HA_list
}

get_server_account_diff() {
    # Get a diff in text file.

    # Getting servers name/ip.
    while read line; do

        echo "$line" | grep -q "^.*#"
        if [ $? -eq 0 ]; then continue; fi

        server1_hostname=$(echo $line | cut -d',' -f1)
        server1_ip=$(echo $line | cut -d',' -f2)
        server2_hostname=$(echo $line | cut -d',' -f3)
        server2_ip=$(echo $line | cut -d',' -f4)
        echo checking server $server1_hostname , $server2_hostname # DEBUG

        su $remote_user -c "ssh $remote_user@$server1_ip "cat /etc/passwd |
            sort | cut -d':' -f1"" </dev/null >$temp1
        su $remote_user -c "ssh $remote_user@$server2_ip "cat /etc/passwd |
            sort | cut -d':' -f1"" </dev/null >$temp2

        diff $temp1 $temp2 >$diff_temp
        if [ $? -eq 0 ]; then
            echo "兩台帳號一樣喔"
            continue
        fi

        echo "============================================="
        echo $server1_hostname 與 $server2_hostname 存在帳號差異
        awk -v server1_hostname=$server1_hostname \
            -v server2_hostname=$server2_hostname \
            /\</'{print server1_hostname,"多了此帳號", $2}\
            /\>/{print server2_hostname, "多了此帳號",$2}' $diff_temp

    done <$HA_server_name_and_ip
}

clear_temp_file() {
    rm $temp1
    rm $temp2
    rm $diff_temp
}

main() {
    #create_mapping
    get_server_account_diff
    clear_temp_file
}
main
