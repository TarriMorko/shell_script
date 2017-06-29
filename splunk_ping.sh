#!/bin/sh
#
#
# splunk_ping.sh
#
# 讀入一個字典檔 HOST_MAPPING_FILE, 裡面是兩台成對的機器 A, B，如果本機是 A 就 ping B
# 是 B 就 ping A
# 另有一個 IP_TABLE 檔, hostname 與 ip 的對應需從此檔查詢
# 這個 script 必須相容於 AIX 5.3/7.1

IP_TABLE="splunk_ping_iptable.txt"
# hostname ip 
HOST_MAPPING_FILE="splunk_ping_map.txt"
# couple host


get_ip_from_host() {
    #######################################
    # 給一個 hostname 參數, 從 $IP_TABLE 獲得 hostname 參數對應的 ip
    # Globals:
    #    $IP_TABLE
    # Arguments:
    #    $hostname
    # Returns:
    #    0 echo $_ip
    #    1 echo "Can't find any ip with host $1"
    # Example:
    #    somehosts_ip=$(get_ip_from_host twnbap)
    #######################################
    local _target_hostname=$1
    local _host
    local _ip
    while read line; do
        _host=$(echo $line | awk '{print $1}')
        _ip=$(echo $line | awk '{print $2}')
        if [ "${_target_hostname}" = "${_host}" ]; then
            echo $_ip
            return 0
        fi
    done < $IP_TABLE

    echo "Can't find any ip with host $1"
    exit 1
}


get_target_host() {
    #######################################
    # 從 $HOST_MAPPING_FILE 得到與本機對應的主機 ip
    # Globals:
    #    $HOST_MAPPING_FILE
    # Returns:
    #    0 與本機對應的機器的 ip
    #    1 echo "Can't find my hostname in $HOST_MAPPING_FILE !!"
    #######################################    
    local _thishost
    local _thisip
    local _server_pair_left
    local _server_pair_right

    _thishost=$(hostname)
    _thisip=$(get_ip_from_host $_thishost)
    while read line; do
        echo $line
        echo "${line}" | grep -q $_thishost
        if [ $? -eq 0 ]; then
            _server_pair_left=$(echo $line | awk '{print $1}')
            _server_pair_right=$(echo $line | awk '{print $2}')

            if [ "${_thishost}" = "${_server_pair_left}" ]; then
                # 如果本機名稱在左，就查詢右邊機器的 ip
                get_ip_from_host $_server_pair_right && return 0
            else
                get_ip_from_host $_server_pair_left && return 0
            fi
        fi
    done <$HOST_MAPPING_FILE

    
    exit 1
}


ping_with_packet_loss(){
    ping -c 5 $1 | grep "packet"
}


main() {
    ip=$(get_target_host)  \
        || echo "Can't find my hostname in $HOST_MAPPING_FILE !!" ;exit 1
    ping_with_packet_loss $ip
}
main
exit 0
