@echo off
REM ==========================================================
REM Script: GenDump.bat
REM Version: 1.1
REM Date: 101/07/19
REM By: Nicky Huang
REM Description:
REM 1. 手動產生 WAS v7 Server 的 JavaCore Dump 與 Heap Dump
REM 2. 前置動作需新增系統變數 IBM_JAVACOREDIR / IBM_HEAPDUMPDIR 
REM    來定義各 Dump 輸出路徑
REM 3. 請參閱下述說明以設定 sw 調整產生內容, 預設為1
REM ==========================================================
REM -----------------------------------------------
REM 變數設定:
REM 1.) 設定 Switch:
REM     sw==1 : 手動產生 JavaCore DUMP
REM     sw==2 : 手動產生 Heap Dump
REM     sw==3 : 手動產生 JavaCore DUMP 及 Heap Dump 
REM     其他值: 不執行任何動作,程式結束.
REM 2.) 設定 AP Server Profile Path
REM     ex:ProfilePath=C:\WebSphere\AppServer\profiles\AppSrv01\
REM 3.) 設定啟用 wsadmin 工具的帳號密碼
REM     -user <WAS Admin 帳號>
REM     -password <WAS Admin 密碼>
REM 4.) 設定 AP Server Name
REM     ap_process=<伺服器名稱>
REM -----------------------------------------------
set sw=3
set ProfilePath=D:\IBM\WebSphere85e\AppServer\profiles\AppSrv01
set wsuser=wasadmin
set wspw=wasadmin
set ap_process=server1


REM 產生手動 Dump 之 command
set genJavaCore="AdminControl.invoke(jvm, 'dumpThreads')"
set genHeapDump="AdminControl.invoke(jvm, 'generateSystemDump')"
set jvm_string="jvm = AdminControl.completeObjectName('type=JVM,process=%ap_process%,*')"

if %sw%==1  (

echo ----------------- GenDump.bat generating JavaCore Dump Begin -----------------
%ProfilePath%\bin\wsadmin.bat -user %wsuser% -password %wspw% -lang jython -c %jvm_string% -c %genJavaCore%
echo ----------------- GenDump.bat generating JavaCore Dump End -----------------

) else if %sw%==2 (

echo ----------------- GenDump.bat generating Heap Dump Begin -----------------
%ProfilePath%\bin\wsadmin.bat -user %wsuser% -password %wspw% -lang jython -c %jvm_string% -c %genHeapDump%
echo ----------------- GenDump.bat generating Heap Dump End -----------------

) else if %sw%==3 (

echo --------------- GenDump.bat generating JavaCore/ Heap Dump Begin ---------------
%ProfilePath%\bin\wsadmin.bat -user %wsuser% -password %wspw% -lang jython -c %jvm_string% -c %genJavaCore% -c %genHeapDump%
echo --------------- GenDump.bat generating JavaCore/ Heap Dump End ---------------

) else (

  echo Switch Option set to Off, Gendump.bat now stopping...

)
