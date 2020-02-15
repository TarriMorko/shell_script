#!/bin/sh

echo
printf "%-10s %-35s %-32s %-32s\n" user user_groups last_password_update account_create_date
echo

for user in $(cat /etc/passwd | awk -F':' '{print $1}');do

  last_password_update=$(lastlog -u $user | grep -v Username | sed s/$user//g | sed 's/pts\/.//g' | sed 's/tty.//g')
  last_password_update=$(echo $last_password_update | sed 's/^[ \t]*//;s/[ \t]*$//')
  if [ -d /home/$user ]; then
    acc_create_date=$(stat /home/$user | grep Modify | awk '{print $2, $3}')
  else
    acc_create_date=""
  fi
  user_groups=$(groups $user | awk -F":" '{print $NF}')
  printf "%-10s %-35s %-32s %-32s\n" "$user" "${user_groups}" "${last_password_update}" "${acc_create_date}"
done
