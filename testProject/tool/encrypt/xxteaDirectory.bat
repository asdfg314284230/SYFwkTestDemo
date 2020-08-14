@echo off
REM 打包框架Lua脚本
REM 当前盘符：%~d0
REM 当前路径：%cd%
REM 当前执行命令行：%0
REM 当前bat文件路径：%~dp0
REM 当前bat文件短路径：%~sdp0
REM 声明采用UTF-8编码

cd %~dp0
:: 工程目录所在地 C:\Users\Administrator\Desktop\sProject
set PROJECT_ROOT = C:\Users\Administrator\Desktop\sProject

:: 加密文件
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\client\config %~dp0\encrypt\config xProject
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\client\game %~dp0\encrypt\game xProject
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\server\script\src\network %~dp0\encrypt\game\network xProject

:: copy 未加密的pb到game中替换
copy %~dp0..\..\src\client\game\pb %~dp0\encrypt\game\pb



pause