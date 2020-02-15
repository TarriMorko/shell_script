PATH=/usr/sbin:$PATH
export PATH
id1=$(who am i | awk '{print $6}')
logfile=/home/logadmin/secadmlog
clear
while true; do
  clear
  echo "           "
  echo "           "
  echo "                           合作金庫銀行資料管制科使用者管理畫面  "
  echo "                      =========================================="
  echo "           "
  echo "                                 1. 帳號管理                 "
  echo "                                 2. 列出系統現有帳號         "
  echo "                                 3. 列出系統現有群組         "
  echo "                                 4. 列出帳號與群組檔案(/etc/passwd,/etc/group)       "
  echo "                                 5. 重置使用者login fail counter "
  echo "                                 6. 密碼最後修改日期 "
  echo "                                 0. 離開                     "
  echo "           "
  echo -e "                                 請選擇功能-->\c"
  read a
  case "$a" in
  "0")
    echo "logout"
    exit
    ;;
  "1")
    sudo /sbin/yast2 users
    ;;
  "2")
    echo ======= 帳號 ==========
    echo "  userid  :    group  "
    echo " ---------------------"
    for i in $(cat /etc/passwd | sed s/\:/" "/g | awk '{print $1}'); do
      id $i | sed s/gid/" : gid"/g | sed s/\(/" "/g | sed s/\)/" "/g | awk '{print $2,$3,$5,$7,$9,$11,$13,$15,$17,$19,$21,$23,$25,$27,$29,$31,                        $33,$35,$37,$39}'
    done
    echo -----------------------
    echo "請按Enter鍵繼續"
    read anykey
    ;;
  "3")
    echo ======= 群組 ==========
    echo "  group   :    userid "
    echo " ---------------------"
    cat /etc/group | sed s/\:/" "/g | awk '{print $1,": "$4}' | sed s/,/" "/g
    echo -----------------------
    echo "請按Enter鍵繼續"
    read anykey
    ;;
  "4")
    echo "======= 帳號檔案(/etc/passwd) =========="
    /bin/cat /etc/passwd | more
    echo "======= 群組檔案(/etc/group) =========="
    /bin/cat /etc/group | more
    echo "請按Enter鍵繼續"
    read anykey
    ;;
  "5")
    clear
    echo "請輸入欲重置之使用者名稱"
    read uname
    echo 目前系統user login fail counter status ......
    echo -e "您確定要重置" $uname "login fail counter?(y/n)"
    read yn
    if test "$yn." = "y."; then
      sudo /sbin/pam_tally2 --reset -u $uname
      echo "重置完成"
      echo 重置後目前系統user login fail counter status ......
      sudo /sbin/pam_tally2 --reset -u $uname
      sleep 2
    else
     echo "放棄重置"
      sleep 2
    fi
    ;;
  "6")
    echo ======= 密碼修改日期 ==========
    echo "  user   :    date "
    for user in $(cat /etc/passwd | awk -F':' '{print $1}'); do
      echo -n $user
      (export LC_ALL=POSIX;chage -l $user) | grep 'Last password change'| awk -F':' '{print "\t\t",$NF}'
    done
    read anykey
    ;;
   *)
    echo "選擇錯誤"
    ;;
  esac
done
