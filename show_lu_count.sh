#!/bin/sh
#
# check_lu.sh  <OZAKLY@tcb-bank.com.tw>
###############################################################################
# Globals variable :
#   Link_station
#   normal_SSCP_count 
#   normal_LU_count             
#   normal_LU62
# Arguments:
#   REMOTE_CALL                 # First arg. Apply "True" if call from ssh.
# Returns:
#    OUTPUTFILE
#
#######################################

REMOTE_CALL=$1

# pu
Link_station="PTREAX"

# lu0
normal_SSCP_count="20"
normal_LU_count="20"

# lu62
normal_LU62[0]='CBNET.EAIMB1P     CBNET.DLURT1      CPSVCMG'
#normal_LU62[1]='CBNET.LTREAA      CBNET.MQMP62      SNASVCMG'
#normal_LU62[2]='CBNET.LTREAA      CBNET.MQMQ62      PARALLEL'
#normal_LU62[3]='CBNET.LTREAA      CBNET.MQMQ62      SNASVCMG'

# temp
_normal_LU62="$RANDOM"_temp


_echo() {
# keep silence in some condition
    if [ "$REMOTE_CALL" == "True" ]; then
        return 0
    fi
    log_message=$@
    # echo "$(date +"%Y-%m-%d %H:%M:%S") ${log_message}"
    echo ${log_message}
}


# pu
check_pu() {
    sna -d l | grep -q $Link_station
    if [ $? == "0" ]; then
        _echo "$(hostname) pu good"
        return 0
    else
        _echo "$(hostname) pu error, please call DC team"
        return 1
    fi

}


check_SSCP() {
    if [[ -z "$normal_SSCP_count" ]]; then
        return 0
    fi

    SSCP_count=$(sna -d s123 | grep "Unkn SSCP-LU" | wc -l)
    if  [[ $SSCP_count -eq $normal_SSCP_count ]]; then
        _echo "$(hostname) SSCP good"
        return 0
    else
        _echo "$(hostname) SSCP error, please call DC team"
        return 1
    fi
    
}


check_lulu() {
    if [[ -z "$normal_LU_count" ]]; then
        return 0
    fi    
    LU_count=$(sna -d s123 | grep "Unkn LU-LU" | wc -l)
    if  [[ $LU_count -eq $normal_LU_count ]]; then
        _echo "$(hostname) LU-LU good"
        return 0
    else
        _echo "$(hostname) LU-LU error, please call AP team"
        return 1
    fi
}


check_lu0() {
    check_SSCP || return 1
    check_lulu || return 1
}


check_lu62() {
    sna -d sl > $_normal_LU62

    LU62_count=${#normal_LU62[@]}
    count=0
    while [[ $count < $LU62_count ]]; do
        cat $_normal_LU62 | grep -q "${normal_LU62[$count]}"
        if ! [ $? -eq 0 ]; then
            _echo "$(hostname) LU62 error, please call MQ team"
            rm $_normal_LU62
            return 1
        fi
		let count=count+1
    done

    _echo "$(hostname) LU62 good"
    rm $_normal_LU62
    return 0
}



main() {
    check_pu  || return 1
    check_lu0 || return 1
    check_lu62 || return 1
}
main