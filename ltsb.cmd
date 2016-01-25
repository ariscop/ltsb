@echo off

rem Mount the Windows 10 Enterprise 2015 LTSB install.wim
rem and put its path in MOUNTDIR below

set MOUNTDIR=C:\path\to\mount

echo %MOUNTDIR%

call :removeOneDrive
call :disableFirstSignIn
call :scDiagTrack
call :scdmwappushservice
call :applyPolicies
pause

exit

:removeOneDrive
SETLOCAL
echo Removing OneDrive...
echo.

call :forceDeleteFile %MOUNTDIR%\Windows\System32\OneDriveSetup.exe
call :forceDeleteFile %MOUNTDIR%\Windows\System32\OneDriveSettingSyncProvider.dll

call :forceDeleteFile %MOUNTDIR%\Windows\SysWow64\OneDriveSetup.exe
call :forceDeleteFile %MOUNTDIR%\Windows\SysWow64\OneDriveSettingSyncProvider.dll

reg load HKLM\_ltsb %MOUNTDIR%\Users\default\ntuser.dat
reg delete HKLM\_ltsb\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v OneDriveSetup /f
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

:scDiagTrack
SETLOCAL
echo Removing DiagTrack service...
echo.
reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SYSTEM
reg delete HKLM\_ltsb\ControlSet001\Services\DiagTrack /f
reg unload HKLM\_ltsb

call :forceDeleteFile %MOUNTDIR%\Windows\System32\diagtrack.dll
call :forceDeleteFile %MOUNTDIR%\Windows\System32\diagtrack_win.dll
call :forceDeleteFile %MOUNTDIR%\Windows\System32\diagtrack_wininternal.dll

goto :eof
ENDLOCAL

:scdmwappushservice
SETLOCAL
echo Removing dmwappushservice service...
echo.
reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SYSTEM
reg delete HKLM\_ltsb\ControlSet001\Services\dmwappushservice /f
reg unload HKLM\_ltsb

call :forceDeleteFile %MOUNTDIR%\Windows\System32\dmwappushsvc.dll

goto :eof
ENDLOCAL

:applyPolicies
SETLOCAL
echo Applying policies...
echo.

reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SOFTWARE

reg add "HKLM\_ltsb\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\_ltsb\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\_ltsb\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f
reg add "HKLM\_ltsb\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f
reg add "HKLM\_ltsb\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d 0 /f
reg add "HKLM\_ltsb\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "value" /t REG_DWORD /d 0 /f

reg unload HKLM\_ltsb
goto :eof
ENDLOCAL

rem This isn't used by default, but good to have just in case.
:killUpdates
SETLOCAL

reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SOFTWARE
reg add HKLM\_ltsb\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\_ltsb\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f
reg unload HKLM\_ltsb

ENDLOCAL

:forceDeleteFile
SETLOCAL
takeown /f "%~1"
icacls "%~1" /grant Everyone:F /q
del /q "%~1"
goto :eof
ENDLOCAL
