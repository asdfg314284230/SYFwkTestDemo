@echo off
cd %~dp0
:: 加密文件
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\client\config %~dp0\encrypt\config xProject
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\client\game %~dp0\encrypt\game xProject
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\src\server\script\src\network %~dp0\encrypt\game\network xProject
%~dp0\Debug\tool_project.exe xxteaDirectory %~dp0..\..\..\..\ThinkDemoProject\ThinkLuaFwk\fwk %~dp0\encrypt\fwk xProject
REM %~dp0\Debug\tool_project.exe xxteaDirectory M:\ThinkDemoProject\ThinkLuaFwk\fwk xProject

:: copy 复制未加密的PB
copy %~dp0..\..\src\client\game\pb %~dp0\encrypt\game\pb

:: 复制文件到外面主目录
xcopy %~dp0encrypt %~dp0..\..\src_encrypt  /e 