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

diff_temp="$RANDOM"_temp
HCAMP_MAPPING_FILE="splunk_ping_map.txt"

create_today_serverlist(){
    # 返回要檢查的伺服器之列表.
    
    # 搜尋 tsmbk 的 /source/opuse 目錄之下所有今天產生的子目錄
    # 如果含有 passwd 這個檔、就返回伺服器名稱，例：
    #
    # /source/opuse/a1_20170716/passwd
    #               ^^ 這裡就是伺服器名稱
    find /source/opuse/*$(date +%Y%m%d)* -maxdepth 1 -type f -name passwd \
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
    #    $_server
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
                # 如果本機名稱在左，就進入比對函式
                # 這樣做是為了避免重複比對
                diff_etc_passwd_of_those_two_server \
                    $_server_pair_left $_server_pair_right
            fi
        fi
    done <$HCAMP_MAPPING_FILE
}


diff_etc_passwd_of_those_two_server(){
    #######################################
    # 給兩個主機名稱，去 tsmbk 上的某資料夾尋找他們今天的 passwd 然後做帳號比對
    # Globals:
    # Arguments:
    #    $server $server2
    # Returns:
    #    0
    #    1
    # Example:
    #    compare_user_of_this_server server1
    #######################################   
    local _server1=$1
    local _server2=$2
    echo $_server1, $_server2
    diff /source/opuse/${_server1}_$(date +%Y%m%d)/passwd \
        /source/opuse/${_server2}_$(date +%Y%m%d)/passwd >$diff_temp
    if [ $? -eq 0 ]; then
        echo "$_server1 $_server2 兩台帳號一樣喔"
        return 0
    fi

    echo "============================================="
    echo $_server1 與 $_server2 存在帳號差異
    awk -v _server1=$_server1 \
        -v _server2=$_server2 \
        /\</'{print _server1,"多了此帳號", $2}\
        /\>/{print _server2, "多了此帳號",$2}' $diff_temp
    # /source/opuse/a1_20170714/passwd.txt
    # /source/opuse/b1_20170714/passwd.txt
}


main(){
    server_list=$(create_today_serverlist)
    if [ -z "${server_list}" ]; then
        echo  '產生伺服器列表失敗。'
        exit 1
    fi

    for server in $server_list
    do
        compare_user_of_this_server $server
    done
    rm $diff_temp
}
main
