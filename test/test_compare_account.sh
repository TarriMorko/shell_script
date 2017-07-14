

test_create_today_serverlist(){
    server_list=$(create_today_serverlist) || {
        assertTrue '產生伺服器列表失敗。'  '1'
    }
    assertNotNull '伺服器列表為空' ${#server_list}
}

oneTimeSetUp() {
    # load include to test
    . ./compare_account.sh
    assertTrue 'compare_account.sh 不存在。' "[ -r compare_account.sh ]"
}
. ./test/shunit2
