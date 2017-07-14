#!/bin/sh
#
#
# compare_account.sh
# 調查遠端 HA 機器的使用者帳號是否相同
# 
# 這支 script 會檢查每天 tsmbk 收到的各主機帳號資訊，比對其中屬於成對的主機資料
# 分析其中是否有不同的使用者帳號，最後產出一個檔案

# 我想一下怎麼弄
# 1. 我需要先找到今天的資料夾
# /source/opuse/$(hostname)_20170714 類似這樣
# server_list=$(find /source/opuse/*$(date +%Y%m%d)* -maxdepth 1 -type d | awk -F'/' '{print $4}' | awk -F'_' '{print $1}')
# 2. 今天的資料夾裡面有哪些主機，這會是一個列表

# 3. 讀入設定檔，這個設定檔裡面說明了哪些主機是成對的
# 4. 迭代資料夾裡的主機名稱，如果有成對的，就開始比較
# 5. 比較結果先吐到一個檔案裡好了

# Q: 怎麼避免成對的機器被比對兩次？
# A: 我迭代一次左列表就可以了, 以左邊為準

HCAMP_MAPPING_FILE="splunk_ping_map.txt"

create_today_serverlist(){
    find /source/opuse/*$(date +%Y%m%d)* -maxdepth 1 -type d \
        | awk -F'/' '{print $4}' \
        | awk -F'_' '{print $1}'
}

compare_user_of_this_server(){
    #######################################
    # 給一個 hostname 參數, 如果在主機對應檔中這個 hostname 在左手邊的話，就執行
    # 帳號比對
    # Globals:
    #    $HCAMP_MAPPING_FILE
    # Arguments:
    #    $hostname
    # Returns:
    #    0
    #    1
    # Example:
    #    compare_user_of_this_server server1
    #######################################
    local _server=$1
    while read line; do
        echo "${line}" | grep -q -w $_server
        if [ $? -eq 0 ]; then
            _server_pair_left=$(echo $line | awk '{print $1}')
            _server_pair_right=$(echo $line | awk '{print $2}')

            if [ "${_server}" = "${_server_pair_left}" ]; then
                # 如果本機名稱在左，就查詢右邊機器的 ip
                echo "去做比對"
            fi
        fi
    done <$HCAMP_MAPPING_FILE
}

main(){
    server_list=$(create_today_serverlist) || {
        echo  '產生伺服器列表失敗。'
        exit 1
    }
    for server in $server_list
    do
        compare_user_of_this_server server
    done
    
}
main
