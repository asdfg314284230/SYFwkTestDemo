@echo off
:begin

echo.

xcopy C:\Users\Administrator\Desktop\Slua\*.lua  D:\SUnityProject\src\client\config /e /y /f 
echo  copy client  finish!
echo.
xcopy C:\Users\Administrator\Desktop\Slua\*.lua  D:\SUnityProject\src\server\script\conf /e /y /f 

echo  copy server  finish!
echo.
pause
