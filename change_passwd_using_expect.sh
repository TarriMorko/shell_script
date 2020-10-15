#!/bin/sh

main_password='1qaz@WSX'
tmp1_password='2wsx#EDC'
tmp2_password='3edc\$RFV'
tmp3_password='4rfv%TGB'
tmp4_password='5tgb^YHN'
tmp5_password='6yhn&UJM'

change_password() {
  origin_password=$1
  new_password=$2

  expect -c "
    spawn passwd;
    expect Old;
    send \"${origin_password}\r\";

    expect New;
    send \"${new_password}\r\";

    expect Reenter;
    send \"${new_password}\r\";

    expect eof;
  "
}

change_password $main_password $tmp1_password
change_password $tmp1_password $tmp2_password
change_password $tmp2_password $tmp3_password
change_password $tmp3_password $tmp4_password
change_password $tmp4_password $tmp5_password
change_password $tmp5_password $main_password
