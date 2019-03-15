#!/bin/sh
#
#
SYSTEM="網路銀行"
ENVIRONMENT="正式機"
logdate=`date +%Y-%m-%d`

echo '  +====================================================================+'
echo "       Hostname: ${HOSTNAME}               ${SYSTEM}環境: ${ENVIRONMENT}"
echo '  +====================================================================+'

echo "輸入的參數是： $@"
echo "真的要執行 ??"

echo "請輸入 Y/y"

read input
# if ! [[ "${input}" = +([Yy]) ]] ; then  # FOR AIX
if ! [[ "${input}" =~ [Yy] ]]; then       # FOR Linux
  echo "不執行, 退出"
  exit 1
fi

db2 $@
