@echo off

set MOUNTDIR=C:\Users\Zane\Desktop\ltsb

echo %MOUNTDIR%

call :removeOneDrive
call :disableFirstSignIn
call :removeQuickAccess
pause

exit

:removeOneDrive
SETLOCAL
echo Removing OneDrive...
echo.

takeown /f %MOUNTDIR%\Windows\System32\OneDriveSetup.exe
icacls %MOUNTDIR%\Windows\System32\OneDriveSetup.exe /grant Everyone:F /q
del /q %MOUNTDIR%\Windows\System32\OneDriveSetup.exe

takeown /f %MOUNTDIR%\Windows\SysWow64\OneDriveSetup.exe
icacls %MOUNTDIR%\Windows\SysWow64\OneDriveSetup.exe /grant Everyone:F /q
del /q %MOUNTDIR%\Windows\SysWow64\OneDriveSetup.exe

reg load HKLM\_ltsb %MOUNTDIR%\Users\default\ntuser.dat
reg delete HKLM\_ltsb\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v OneDriveSetup /f
reg unload HKLM\_ltsb

goto :eof
ENDLOCAL

:disableFirstSignIn
SETLOCAL
echo Disabling First Logon Animation...
echo.

reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SOFTWARE
reg add HKLM\_ltsb\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f
reg unload HKLM\_ltsb

goto :eof
ENDLOCAL

:removeQuickAccess
SETLOCAL
echo Removing Quick Access...
echo.

reg load HKLM\_ltsb %MOUNTDIR%\Users\default\ntuser.dat
reg add HKLM\_ltsb\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f
reg unload HKLM\_ltsb

goto :eof
ENDLOCAL
