#!/bin/sh
#
#
# 建置帳號對程式及資料檔案相關權限之檢查功能介面，於帳號清查作業時一併列示清查
# 使用前請先定義 以下參數
# DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION  #掃描這些目錄下所有檔案與目錄的權限
# DIRECTORY_YOU_WANT_TO_CHECK_MD5         #掃描這些目錄下所有檔案的hash
# DIRECTORY_YOU_WANT_TO_CHECK             #檢查誰可以存取這些目錄

## USER STORY

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

# Changelog

## [Unreleased]
# AIX 有 suid 的部分，在比對檔案權限時有問題(多一個 suid欄位)
# 產生檔案與目錄權限基準檔 但是要by帳號

##
## [0.8] - 2018-08-10
### fixed
# - 保留 1, 2, 3, 4, 11 項功能
# - 11. 改為 5. 其餘刪除

##
## [0.7.5] - 2018-07-27
### Added
# - 12. 列出某帳號可以讀取、寫入、執行、哪些目錄以及其子目錄

##
## [0.7] - 2018-07-27
### Added
# - 11. 列出某帳號可以讀取、寫入、執行、哪些目錄

## [0.6] - 2018-07-26
### Added
# - 8. 列出某帳號可以讀取哪些目錄
# - 9. 列出某帳號可以寫入哪些目錄
# - 10. 列出某帳號可以執行哪些目錄

## [0.5] - 2018-07-25
### Added
# - 指定一或多個目錄，列出哪些帳號具有該目錄的「讀取」權限
# - 指定一或多個目錄，列出哪些帳號具有該目錄的「寫入」權限
# - 指定一或多個目錄，列出哪些帳號具有該目錄的「執行」權限
### Fixed
# - 檢查檔案權限 改為 檢查檔案及目錄權限
# - 產生檔案權限基準檔 改為 產生檔案及目錄權限基準檔
# - 移除查「某個帳號」在「某個目錄」下、同時「讀取、寫入、執行」權限的所有目錄
# - 移除查「某個帳號」在「某個目錄」下、有讀取/寫入/執行權限的所有目錄

## [0.4] - 2018-06-05
### Added
# - 增加功能8, 查「某個帳號」在「某個目錄」下、同時「讀取、寫入、執行」權限的所有目錄
# - 增加三個 func, 查「某個帳號」在「某個目錄」下、有讀取/寫入/執行權限的所有目錄

## [0.3] - 2018-05-16
### Fixed
# - 修正 linux 的部分，已在 SuSE12sp1, Centos7.4 測試過.
# - AIX 的部分測試完了.

## [0.2] - 2018-05-11
### Fixed
# - 修正 check_permission_and_md5 的AIX istat換行.

## [0.1] - 2018-05-07
### Added
# - First audit release.
# - 1. 檢查檔案權限
# - 2. 檢查檔案 hash
# - 3. 產生檔案權限基準檔      
# - 4. 產生檔案 hash 基準檔
# - User story.

_HOME="/src/mwadmin/check_permission_and_md5"

BASE_PERMISSION="$_HOME/BASE_PERMISSION"
PERMISSION_REPORT="$_HOME/PERMISSION_report_$(hostname)_$(date +%Y%m%d).txt"
DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION="/bin /sbin /usr/bin /usr/sbin /etc"

BASE_MD5="$_HOME/BASE_MD5"
MD5_REPORT="$_HOME/MD5_report_$(hostname)_$(date +%Y%m%d).txt"
DIRECTORY_YOU_WANT_TO_CHECK_MD5=$DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION

DIRECTORY_YOU_WANT_TO_CHECK="/home /home/spos2 /src"

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

      1. 檢查檔案與目錄權限
      2. 檢查檔案 hash

      3. 產生檔案與目錄權限基準檔
      4. 產生檔案 hash 基準檔
      
      5. 列出某帳號可以讀取、寫入、執行、哪些目錄

      q.QUIT

EOF
}

list_dirs_permissions_by_user() {
  # 取出 /etc/passwd 中，sh 為 /bin/bash 或 /bin/ksh 的帳號
  # 檢查這些帳號是否可以 read write exec 變數 DIRECTORY_YOU_WANT_TO_CHECK 中指定的目錄
  # 以帳號別列出
  #
  # 範例

  # spos2    read       exec /home

  ids=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')

  for id in $ids; do

    for _dir in $DIRECTORY_YOU_WANT_TO_CHECK; do

      _readable=""
      _writable=""
      _execable=""

      su - $id -c "test -r '$_dir'" >/dev/null 2>&1 && _readable="read"
      su - $id -c "test -w '$_dir'" >/dev/null 2>&1 && _writable="write"
      su - $id -c "test -x '$_dir'" >/dev/null 2>&1 && _execable="exec"

      printf "%-8s %-4s %-5s %-4s %-s \n" $id "$_readable" "$_writable" "$_execable" "$_dir"
    done

    echo ""
  done
}

create_base_permission() {
  # 依照 DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION 所指定的目錄
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
  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION; do
    echo "Parsing $dir permission now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir | grep -v -f exclude_file); do
        stat -c '%n %A %g %u' $i >>$BASE_PERMISSION
      done

    else

      for i in $(find $dir | grep -v -f exclude_file); do
        echo $i" \c" >>$BASE_PERMISSION
        istat $i | tr '\n' ' ' | awk '{print $8, $10, $12}' >>$BASE_PERMISSION
      done

    fi

  done
}

create_permission_today() {
  # 依照 DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION 所指定的目錄
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
  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION; do
    echo "Parsing $dir permission now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir | grep -v -f exclude_file); do
        stat -c '%n %A %g %u' $i >>$_permission_today
      done

    else

      for i in $(find $dir | grep -v -f exclude_file); do
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
  # 依照 DIRECTORY_YOU_WANT_TO_CHECK_MD5 所指定的目錄
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
  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_MD5; do
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
  # 依照 DIRECTORY_YOU_WANT_TO_CHECK_MD5 所指定的目錄
  # 排除檔案 exclude_file 中列舉的檔案名稱  
  # 產生 md5 列表至 $_md5_today
  #
  # 檔案格式為 hash字串 full檔案路徑
  # 範例：
  # 85bc0fd26b358ea8edc0d4cab5e92044  /usr/bin/oldfind
  # 795ad904fe7001acae1a149c4cd1ff3d  /usr/bin/catchsegv
  # 2098c131c6f1f63777e9678b4be4e752  /usr/bin/xargs

  _md5_today="$RANDOM"_temp

  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_MD5; do
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
    # echo "MD5 Audit passed." >>$MD5_REPORT
  else
    echo "檢查結果："
    echo "============================================================="
    cat $MD5_REPORT | grep ">\|<" | awk '{print $NF}' | sort | uniq | xargs -I {} echo "這些檔案發生變動： {}"
    echo "============================================================="
    echo "MD5 Audit failed."
    echo "check $MD5_REPORT for detail."
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
    5) list_dirs_permissions_by_user ;;
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
