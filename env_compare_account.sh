#!/bin/sh
#Description: Only modify the files and directories created from today.
#             rename passwd file and move passwd file to directory,
#             modify permission for passwd file(644) and directory(755).
#             Must run as root.
#Write by Ken (kenpeng@tiis.com.tw)
#date: 2017-11-08
#Version: v1.0

# Check today's target exist?
ls -ld /source/opuse/*$(date +%Y%m%d) 1> /dev/null 2> /dev/null
[ $? -ne 0 ] && echo -e "\n\t Did not find today's file or directory ! \n\n" && exit 1

dirList="$RANDOM"_temp
fileList="$RANDOM"_temp

# Convert file and move to the directory, and rename it to passwd
ls -ld /source/opuse/*$(date +%Y%m%d) 2> /dev/null | grep "^-" | awk '{print $9}' > ${fileList}
if [ -s ${filelist} ]
then
    while read LINE
    do
        mv ${LINE} ${LINE}_passwd
        mkdir ${LINE}
        mv ${LINE}_passwd ${LINE}/passwd
        #chmod 644 ${LINE}/passwd
    done < ${fileList}
fi

# modify file & directory permission
ls -ld /source/opuse/*$(date +%Y%m%d) 2> /dev/null | grep "^d" | awk '{print $9}' > ${dirList}
if [ -s ${dirList} ]
then
    while read LINE
    do
        chmod -R 644 ${LINE}
        chmod 755 ${LINE}
    done < ${dirList}
fi

rm -f ${dirList} ${fileList}

