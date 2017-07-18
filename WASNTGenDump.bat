@echo off
REM ==========================================================
REM Script: GenDump.bat
REM Version: 1.1
REM Date: 101/07/19
REM By: Nicky Huang
REM Description:
REM 1. ��ʲ��� WAS v7 Server �� JavaCore Dump �P Heap Dump
REM 2. �e�m�ʧ@�ݷs�W�t���ܼ� IBM_JAVACOREDIR / IBM_HEAPDUMPDIR 
REM    �өw�q�U Dump ��X���|
REM 3. �аѾ\�U�z�����H�]�w sw �վ㲣�ͤ��e, �w�]��1
REM ==========================================================
REM -----------------------------------------------
REM �ܼƳ]�w:
REM 1.) �]�w Switch:
REM     sw==1 : ��ʲ��� JavaCore DUMP
REM     sw==2 : ��ʲ��� Heap Dump
REM     sw==3 : ��ʲ��� JavaCore DUMP �� Heap Dump 
REM     ��L��: ���������ʧ@,�{������.
REM 2.) �]�w AP Server Profile Path
REM     ex:ProfilePath=C:\WebSphere\AppServer\profiles\AppSrv01\
REM 3.) �]�w�ҥ� wsadmin �u�㪺�b���K�X
REM     -user <WAS Admin �b��>
REM     -password <WAS Admin �K�X>
REM 4.) �]�w AP Server Name
REM     ap_process=<���A���W��>
REM -----------------------------------------------
set sw=3
set ProfilePath=D:\IBM\WebSphere85e\AppServer\profiles\AppSrv01
set wsuser=wasadmin
set wspw=wasadmin
set ap_process=server1


REM ���ͤ�� Dump �� command
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
