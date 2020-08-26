@echo off
cd %~dp0
REM :: 加密文件
REM %~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\client\config %~dp0\encrypt\config xProject
REM %~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\client\game %~dp0\encrypt\game xProject
REM %~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\server\script\src\network %~dp0\encrypt\game\network xProject

:: copy 复制未加密的PB
copy %~dp0..\..\src\client\game %~dp0\encrypt\game



REM :: 复制文件到外面主目录
REM xcopy %~dp0encrypt %~dp0..\..\src_encrypt  /e 