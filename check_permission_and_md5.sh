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
## 數分鐘後系統顯示 Audit passed. 或  Audit failed. 並產生報表到指定目錄。
##
## 宗翰做事很有條理
## 宗翰按下任意鍵後，系統顯示兩個選項 "檢查檔案權限" "檢查檔案hash"
##
## 宗翰選擇了"檢查檔案hash"
## 系統顯示 "請稍候片刻"，並且開始蒐集指定宗翰在設定檔中指定目錄的hash
## 數分鐘後系統顯示 Audit passed. 或  Audit failed. 並產生報表到指定目錄。
## 宗翰感覺開心，將報表取出後下班了。

_HOME="/src/mwadmin/check_permission_and_md5"

BASE_PERMISSION="$_HOME/BASE_PERMISSION"
PERMISSION_REPORT="$_HOME/PERMISSION_report_$(hostname)_$(date +%Y%m%d).txt"
DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION="/bin /sbin /usr/bin /usr/sbin /etc"

BASE_MD5="$_HOME/BASE_MD5"
MD5_REPORT="$_HOME/MD5_report_$(hostname)_$(date +%Y%m%d).txt"
DIRECTORY_YOU_WAT_TO_CHECK_MD5=$DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION


if [[ "$(uname)" = "Linux" ]]; then
  OS="Linux"
else
  OS="AIX"
fi

show_main_menu() {
  # Just show main menu.
  clear
  cat <<EOF
  +====================================================================+
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 檢查檔案權限
      2. 檢查檔案 hash

      3. 產生檔案權限基準檔
      4. 產生檔案 hash 基準檔
      
      q.QUIT

EOF
}

create_base_permission() {
  # 依照 DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION 所指定的目錄
  # 排除檔案 exclude_file 中列舉的檔案名稱
  # 產生權限列表至 $BASE_PERMISSION
  #
  # 檔案格式為 檔名, 權限, uid, gid
  # 範例
  # /usr/bin/oldfind -rwxr-xr-x 0 0
  # /usr/bin/catchsegv -rwxr-xr-x 0 0
  # /usr/bin/xargs -rwxr-xr-x 0 0  
  echo "Please wait..."
  rm $BASE_PERMISSION >/dev/null 2>&1
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION; do
    echo "Parsing $dir permission now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        stat -c '%n %A %g %u' $i >>$BASE_PERMISSION
      done

    else

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        echo $i" \c" >>$BASE_PERMISSION
        istat $i | tr '\n' ' ' | awk '{print $8, $10, $12}' >>$BASE_PERMISSION
      done

    fi

  done
}

create_permission_today() {
  # 依照 DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION 所指定的目錄
  # 排除檔案 exclude_file 中列舉的檔案名稱  
  # 產生權限列表至臨時檔案 $BASE_PERMISSION
  #
  # 檔案格式為 檔名, 權限, uid, gid
  # 範例
  # /usr/bin/oldfind -rwxr-xr-x 0 0
  # /usr/bin/catchsegv -rwxr-xr-x 0 0
  # /usr/bin/xargs -rwxr-xr-x 0 0


  echo "Please wait..."
  _permission_today="$RANDOM"_temp
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_PERMISSION; do
    echo "Parsing $dir permission now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        stat -c '%n %A %g %u' $i >>$_permission_today
      done

    else

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        echo $i" \c" >>$_permission_today
        istat $i | tr '\n' ' ' | awk '{print $8, $10, $12}' >>$_permission_today
      done

    fi

  done
}

diff_permission_today_with_BASE() {
  diff $BASE_PERMISSION $_permission_today >$PERMISSION_REPORT
  if [[ $? -eq 0 ]]; then
    echo ''
    echo "Permission Audit passed."
    echo "Permission Audit passed." >>$PERMISSION_REPORT

  else
    echo ''
    echo "Permission Audit failed. check $PERMISSION_REPORT for detail."
    echo "Permission Audit failed." >>$PERMISSION_REPORT
  fi
  rm $_permission_today
}

check_permission() {
  create_permission_today
  diff_permission_today_with_BASE
}

create_base_md5() {
  # 依照 DIRECTORY_YOU_WAT_TO_CHECK_MD5 所指定的目錄
  # 排除檔案 exclude_file 中列舉的檔案名稱  
  # 產生 md5 列表至 $BASE_MD5
  #
  # 檔案格式為 hash字串 full檔案路徑
  # 範例：
  # 85bc0fd26b358ea8edc0d4cab5e92044  /usr/bin/oldfind
  # 795ad904fe7001acae1a149c4cd1ff3d  /usr/bin/catchsegv
  # 2098c131c6f1f63777e9678b4be4e752  /usr/bin/xargs


  echo "Please wait..."
  rm $BASE_MD5 >/dev/null 2>&1
  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_MD5; do
    echo "Parsing $dir hash now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        md5sum $i >>$BASE_MD5
      done

    else

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        csum -h MD5 $i >>$BASE_MD5
      done

    fi

  done
}

create_md5_today() {
  # 依照 DIRECTORY_YOU_WAT_TO_CHECK_MD5 所指定的目錄
  # 排除檔案 exclude_file 中列舉的檔案名稱  
  # 產生 md5 列表至 $_md5_today
  #
  # 檔案格式為 hash字串 full檔案路徑
  # 範例：
  # 85bc0fd26b358ea8edc0d4cab5e92044  /usr/bin/oldfind
  # 795ad904fe7001acae1a149c4cd1ff3d  /usr/bin/catchsegv
  # 2098c131c6f1f63777e9678b4be4e752  /usr/bin/xargs


  _md5_today="$RANDOM"_temp

  for dir in $DIRECTORY_YOU_WAT_TO_CHECK_MD5; do
    echo "Parsing $dir hash now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        md5sum $i >>$_md5_today
      done

    else

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        csum -h MD5 $i >>$_md5_today
      done

    fi
  done

}

diff_md5_today_with_BASE() {
  diff $BASE_MD5 $_md5_today >$MD5_REPORT

  if [[ $? -eq 0 ]]; then
    echo ""
    echo "MD5 Audit passed."
    echo "MD5 Audit passed." >>$MD5_REPORT
  else
    echo ""
    echo "MD5 Audit failed. check $MD5_REPORT for detail."
    echo "MD5 Audit failed." >>$MD5_REPORT
  fi

  rm $_md5_today
}

check_md5() {
  create_md5_today
  diff_md5_today_with_BASE
}

main() {
  # The entry for sub functions.
  while true; do
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
      exit
      logout
      ;;
    *)
      clear
      clear
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
