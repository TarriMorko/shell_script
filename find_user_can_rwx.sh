u=erwin
g=$(id -G "$u" | sed 's/ / -o -group /g')
IFS=" "
find /  \( -user "$u" -perm -u=rwx -o \
          ! -user "$u" \( -group $g \) -perm -g=rwx -o \
          ! -user "$u" ! \( -group $g \) -perm -o=rwx \)