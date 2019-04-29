#!/bin/sh
# 
# Get DB2 performance element below
#
# avg_pages_per_async_read_req
# avg_transaction_rows_read
# hash_join_overflows
# index_read_efficiency
# log_read_hitrate
# num_log_buffer_full
# synchronous_read_percentage
# total_hash_loops

# example
#  ./db2_get_most_eff_element_in_snapshot.sh /cygdrive/c/temp/snapshot.log.03080120

SNAPSHOT=$1

Asynchronous_pool_data_page_reads=$(grep -m 1 "Asynchronous pool data page reads" ${SNAPSHOT} | awk '{print $NF}')
Asynchronous_pool_index_page_reads=$(grep -m 1 "Asynchronous pool index page reads" ${SNAPSHOT} | awk '{print $NF}')
Asynchronous_pool_xda_page_reads=$(grep -m 1 "Asynchronous pool xda page reads" ${SNAPSHOT} | awk '{print $NF}')
Asynchronous_data_read_requests=$(grep -m 1 "Asynchronous data read requests" ${SNAPSHOT} | awk '{print $NF}')
Asynchronous_index_read_requests=$(grep -m 1 "Asynchronous index read requests" ${SNAPSHOT} | awk '{print $NF}')
Asynchronous_xda_read_requests=$(grep -m 1 "Asynchronous xda read requests " ${SNAPSHOT} | awk '{print $NF}')
avg_pages_per_async_read_req=$( echo "scale=3;($Asynchronous_pool_data_page_reads + $Asynchronous_pool_index_page_reads + $Asynchronous_pool_xda_page_reads)/($Asynchronous_data_read_requests + $Asynchronous_index_read_requests + $Asynchronous_xda_read_requests )" | bc -l )
echo "avg_pages_per_async_read_req="$avg_pages_per_async_read_req


Rows_read=$(grep -m 1 "Rows read" ${SNAPSHOT} | awk '{print $NF}')
Commit_statements_attempted=$(grep -m 1 "Commit statements attempted" ${SNAPSHOT} | awk '{print $NF}')
Rollback_statements_attempted=$(grep -m 1 "Rollback statements attempted" ${SNAPSHOT} | awk '{print $NF}')
Internal_commits=$(grep -m 1 "Internal commits" ${SNAPSHOT} | awk '{print $NF}')
avg_transaction_rows_read=$( echo "scale=3;($Rows_read) / ($Commit_statements_attempted + $Rollback_statements_attempted + $Internal_commits)" | bc -l )
echo "avg_transaction_rows_read="$avg_transaction_rows_read


# echo "hash_join_overflows="$(grep -m 1 "Number of hash join overflows" ${SNAPSHOT}  | awk '{print $NF}')


Rows_selected=$(grep -m 1 "Rows selected" ${SNAPSHOT} | awk '{print $NF}')
index_read_efficiency=$( echo "scale=3; $Rows_read / $Rows_selected" | bc -l )
echo "index_read_efficiency="$index_read_efficiency


Number_read_log_IOs=$(grep -m 1 "Number read log IOs" ${SNAPSHOT} | awk '{print $NF}')
Log_pages_read=$(grep -m 1 "Log pages read" ${SNAPSHOT} | awk '{print $NF}')
log_read_hitrate=$( echo "scale=3; (1 - ($Number_read_log_IOs / $Log_pages_read))*100" | bc -l )
echo "log_read_hitrate="$log_read_hitrate "%"


Package_cache_lookups=$(grep -m 1 "Package cache lookups" ${SNAPSHOT} | awk '{print $NF}')
Package_cache_inserts=$(grep -m 1 "Package cache inserts" ${SNAPSHOT} | awk '{print $NF}')
Package_Cache_Hit_Ratio=$( echo "scale=3; (1 - ($Package_cache_inserts / $Package_cache_lookups))*100" | bc -l )
echo "Package_Cache_Hit_Ratio="$Package_Cache_Hit_Ratio "%"

# echo "num_log_buffer_full="$(grep -m 1 "Number log buffer full" ${SNAPSHOT} | awk '{print $NF}' )


# Buffer_pool_data_physical_reads=$( grep -m 1 "Buffer pool data physical reads" ${SNAPSHOT} | awk '{print $NF}')
# Buffer_pool_index_physical_reads=$( grep -m 1 "Buffer pool index physical reads" ${SNAPSHOT} | awk '{print $NF}')
# Buffer_pool_xda_physical_reads=$( grep -m 1 "Buffer pool xda physical reads" ${SNAPSHOT} | awk '{print $NF}')
# Buffer_pool_temporary_data_physical_reads=$( grep -m 1 "Buffer pool temporary data physical reads" ${SNAPSHOT} | awk '{print $NF}')
# Buffer_pool_temporary_index_physical_reads=$( grep -m 1 "Buffer pool temporary index physical reads" ${SNAPSHOT} | awk '{print $NF}')
# Buffer_pool_temporary_xda_physical_reads=$( grep -m 1 "Buffer pool temporary xda physical reads" ${SNAPSHOT} | awk '{print $NF}')
# synchronous_read_percentage=$( echo "scale=3; (100 - ((($Asynchronous_pool_data_page_reads + $Asynchronous_pool_index_page_reads +$Asynchronous_pool_xda_page_reads )*100) / ($Buffer_pool_data_physical_reads + $Buffer_pool_index_physical_reads + $Buffer_pool_xda_physical_reads +$Buffer_pool_temporary_data_physical_reads +$Buffer_pool_temporary_index_physical_reads +$Buffer_pool_temporary_xda_physical_reads )))   "| bc -l)
# echo "synchronous_read_percentage="$synchronous_read_percentage


# echo "total_hash_loops="$(grep -m 1 "Number of hash loops" ${SNAPSHOT}  | awk '{print $NF}')
echo ""
echo "From ${SNAPSHOT} "
