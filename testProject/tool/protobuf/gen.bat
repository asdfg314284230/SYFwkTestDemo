@echo off
REM 打包框架Lua脚本
REM 当前盘符：%~d0
REM 当前路径：%cd%
REM 当前执行命令行：%0
REM 当前bat文件路径：%~dp0
REM 当前bat文件短路径：%~sdp0

chcp 65001

for  %%i in (proto/*.proto) do ( 
    echo %%i 
    REM echo %%~ni
    %~dp0protoc.exe -I%~dp0/proto/ -o %~dp0/pb/%%~ni.pb %~dp0/proto/%%~ni.proto 
)
rem pause
