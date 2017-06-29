#!/bin/sh
#
#
# splunk_ping.sh

# 維護一個 dict, 裡面是兩台機器A、B，如果我是 A 就 ping B
# 是 B 就 ping A
# 這個 script 必須相容於 AIX 5.3/7.1, 幹 Linux 也放進去算了

# 那首先的 dict 要怎麼寫呢
# 乾脆就隨便一個對應檔好了

get_ip_from_host() {
    # 輸入一個 hostname 參數, 從 splunk_ping_iptable.txt 獲得跟 $1 對應的 ip
    local _target_hostname=$1
    local _host
    local _ip
    while read line; do
        _host=$(echo $line | awk '{print $1}')
        _ip=$(echo $line | awk '{print $2}')

        if [ "${_target_hostname}" = "${_host}" ]; then
            echo $_ip
        fi
    done < splunk_ping_iptable.txt
}

get_target_host() {
    # 從 splunk_ping_map.txt 得到與本機對應的 hostname 跟 ip
    local _thishost
    local _thisip
    local _server_pair_left
    local _server_pair_right

    _thishost=$(hostname)
    _thisip=$(get_ip_from_host $_thishost)
    while read line; do
        echo "${line}" | grep -q $_thishost
        if [ $? -eq 0 ]; then
            # get server pair, EX: taaripc, taaripcdb
            _server_pair_left=$(echo $line | awk '{print $1}')
            _server_pair_right=$(echo $line | awk '{print $2}')
            if [ "${_thishost}" = "${_server_pair_left}" ]; then
                # echo $_server_pair_right
                get_ip_from_host $_server_pair_right
            else
                # echo $_server_pair_left
                get_ip_from_host $_server_pair_left
            fi
        fi
    done <splunk_ping_map.txt
}

main() {
    get_target_host
}
main
