QMGRS=$(dspmq | sed 's/).*//g' | sed 's/.*(//g' )

for qmgr in $QMGRS
do

    localqueues=$(echo "dis ql(*)" |runmqsc $qmgr | grep -v SYSTEM | grep -o "QUEUE(.*)" | awk '{print $1}' | cut -d'(' -f2 | cut -d')' -f1)

    for localqueue in $localqueues
    do

        count=$(echo "dis ql($localqueue) curdepth" | runmqsc $qmgr| grep CUR | cut -d'(' -f2  | cut -d')' -f1)

        echo "Warning : The current depth of local queue $localqueue in $qmgr is $count!!"
    done
done
