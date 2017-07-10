# Check LU
if [ "${CHECK_LU}" = "YES" ] ; then
    SSCP_count=$(sna -d s123 | grep "Unkn SSCP-LU" | wc -l)
    LU_count=$(sna -d s123 | grep "Unkn LU-LU" | wc -l)

    if  [[ $SSCP_count -eq $normal_SSCP_count ]]; then
        if  [[ $LU_count -eq $normal_LU_count ]]; then
            # Normal
            printf "\n%-7s Active %2s, %-7s Active %2s, LU State: Normal.\n" SSCP $SSCP_count LU-LU $LU_count
        else
            printf "\n%-7s Active %2s, %-7s Active %2s, LU State: Error.\n" SSCP $SSCP_count LU-LU $LU_count
            echo "Please Call AP Team, Lu-Lu Not Avaliable."
        fi
    else
        printf "\n%-7s Active %2s, %-7s Active %2s, LU State: Error.\n" SSCP $SSCP_count LU-LU $LU_count
        echo "Please Call NetWork Team, SSCP-LU Not Avaliable."
    fi
fi

echo
rm ${TEMP_FILE}
