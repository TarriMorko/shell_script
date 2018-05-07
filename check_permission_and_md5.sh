#!/bin/sh
#
#
# 建置帳號對程式及資料檔案相關權限之檢查功能介面，於帳號清查作業時一併列示清查


## 以下是 user story

## 宗翰正準備執行帳號清查作業，宗翰登入系統打開了 opmenu
## 宗翰選擇了 check_permission_and_md5 項目
## 此時系統顯示兩個選項 "檢查檔案權限" "檢查檔案hash"
## 宗翰選擇了 "檢查檔案權限"
## 系統顯示 "請稍候片刻"，並且開始蒐集指定宗翰在設定檔中指定目錄的檔案權限
## 數分鐘後系統將權限與 baseline 不符合的檔案顯示在螢幕上。並且產生報表到指定目錄。
## 宗翰按下任意鍵後，系統顯示兩個選項 "檢查檔案權限" "檢查檔案hash"
## 宗翰做事很有條理
## 宗翰選擇了"檢查檔案hash"
## 系統顯示 "請稍候片刻"，並且開始蒐集指定宗翰在設定檔中指定目錄的hash
## 數分鐘後系統將 hash 與 baseline 不符合的檔案顯示在螢幕上。並且產生報表到指定目錄。
## 宗翰感覺開心，將報表取出後下班了。


_HOME="/src/mwadmin/check_permission_and_md5"

BASE_PERMISSION="$_HOME/BASE_PERMISSION"
PERMISSION_REPORT="$_HOME/PERMISSION_report_$(hostname)_$(date +%Y%m%d).txt"
DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION="
/bin /sbin /usr/bin /usr/sbin /etc
"

BASE_MD5="$_HOME/BASE_MD5"
MD5_REPORT="$_HOME/MD5_report_$(hostname)_$(date +%Y%m%d).txt"
DIRECTORY_YOU_WAT_TO_CHECK_MD5="
/bin /sbin /usr/bin /usr/sbin /etc
"

if [[ "$(uname)" = "Linux" ]]; then
    OS="Linux"
else
    OS="AIX"
fi


show_main_menu() {
  # Just show main menu.
  clear
  cat << EOF
  +====================================================================+
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 檢查檔案權限
      2. 檢查檔案 hash

      3. 產生檔案權限基準檔     # 產生完之後建議拿掉此選項
      4. 產生檔案 hash 基準檔  # 產生完之後建議拿掉此選項
      
      q.QUIT

EOF
}


create_base_permission() {
  echo "Please wait..."
  rm $BASE_PERMISSION >/dev/null 2>&1
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION ; do
      echo "Parsing $dir now..."

      if [[ $OS = "Linux" ]]; then
        find $dir -type f -exec stat -c '%A %C %F %g %u %s %Y %n' {} \; >> $BASE_PERMISSION
      else  
        find $dir -type f -exec istat {} \; | tr '\n' ' ' >> $BASE_PERMISSION
      fi

  done
}


create_permission_today() {
  # 依照 DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION 所指定的目錄
  # 產生權限列表至臨時檔案 $BASE_PERMISSION
  echo "Please wait..."
  _permission_today="$RANDOM"_temp
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION ; do
      echo "Parsing $dir now..."
      
      if [[ $OS = "Linux" ]]; then
        find $dir -type f -exec stat -c '%A %C %F %g %u %s %Y %n' {} \; >> $_permission_today
      else  
        find $dir -type f -exec istat {} \; | tr '\n' ' ' >> $_permission_today
      fi

  done 
}


diff_permission_today_with_BASE(){
  # 將 create_permission_today 產生的權限列表與 BASE_PERMISSION 做比較
  diff $_permission_today ${BASE_PERMISSION} \
    | tee $PERMISSION_REPORT \
    | grep '>' | awk '{print "Audit failed: ", $NF}'

  diff $_permission_today ${BASE_PERMISSION} -q >/dev/null 2>&1
  if [[ $? -eq 0  ]]; then
    echo ''
    echo "Permission Audit passed."
    echo "Permission Audit passed." > $PERMISSION_REPORT

  else
    echo ''
    echo "Audit failed, check $PERMISSION_REPORT for detail."
  fi
  rm $_permission_today
}


check_permission() {
  create_permission_today
  diff_permission_today_with_BASE
}


create_base_md5() {
  echo "Please wait..."
  rm $BASE_MD5 >/dev/null 2>&1
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_MD5 ; do
      echo "Parsing $dir now..."
      find $dir -type f -exec md5sum {} \; >> $BASE_MD5
  done  
}


create_md5_today() {
  # 依照 DIRECTORY_YOU_WAT_TO_CHECK_MD5 所指定的目錄
  # 產生 md5 列表至臨時檔案 _md5_today

  _md5_today="$RANDOM"_temp
  
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_MD5 ; do
      find $dir -type f -exec md5sum {} \; >> $_md5_today
  done

}


diff_md5_today_with_BASE() {
  # 將 create_md5_today 產生的 md5 列表與 BASE_MD5做比較
  diff $_md5_today ${BASE_MD5} | grep '>' | awk '{print "Audit failed: ", $NF}' > $MD5_REPORT
  diff $_md5_today ${BASE_MD5} -q >/dev/null 2>&1
  if [[ $? -eq 0  ]]; then
    echo ''
    echo "MD5 Audit passed."
    echo "MD5 Audit passed." > $MD5_REPORT

  else
    cat $MD5_REPORT
    echo ''
    echo "Audit failed, check $MD5_REPORT for detail."
  fi
  rm $_md5_today
}


check_md5(){
  create_md5_today
  diff_md5_today_with_BASE
}


main() {
# The entry for sub functions.
  while true
  do
    cd ${_HOME}
    show_main_menu
    read choice
    clear
      case $choice in
      1) check_permission ;;
      2) check_md5 ;;
      3) create_base_permission ;;
      4) create_base_md5 ;;        
      [Qq])
        echo ''
        echo 'Thanks !! bye bye ^-^ !!!'
        echo ''
        exit;logout
        ;;
      *)
        clear;clear
        echo ''
        echo ' !!!  ERROR CHOICE , PRESS ENTER TO CONTINUE ... !!!'
        read choice
        ;;
      esac
      echo ''
      echo 'Press enter to continue' && read null
  done
}

main
