@echo off
call gen
echo.
echo convert protobuf finish!
echo.

set source=%cd%\pb

cd ../..
cd src\client\game\pb
copy %source% %cd% /y

cd ../../..
cd server\script\src\proto
copy %source% %cd% /y
echo.
echo copy finish!
pause