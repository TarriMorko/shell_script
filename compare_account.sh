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

create_today_serverlist(){
    find /source/opuse/*$(date +%Y%m%d)* -maxdepth 1 -type d \
        | awk -F'/' '{print $4}' \
        | awk -F'_' '{print $1}'
}