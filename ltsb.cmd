@echo off

rem Mount the Windows 10 Enterprise 2015 LTSB install.wim
rem and put its path in MOUNTDIR below

set MOUNTDIR=C:\path\to\mount

echo %MOUNTDIR%

call :removeOneDrive
call :scDiagTrack
call :scdmwappushservice
call :applyPolicies
call :fixPhotoViewer
call :killUpdates

pause

goto :end

:removeOneDrive
SETLOCAL
echo Removing OneDrive...
echo.

call :forceDeleteFile "%MOUNTDIR%\Windows\System32\OneDriveSetup.exe"
call :forceDeleteFile "%MOUNTDIR%\Windows\System32\OneDriveSettingSyncProvider.dll"

call :forceDeleteFile "%MOUNTDIR%\Windows\SysWow64\OneDriveSetup.exe"
call :forceDeleteFile "%MOUNTDIR%\Windows\SysWow64\OneDriveSettingSyncProvider.dll"

call :deleteSxSEntry "wow64_microsoft-windows-onedrive-setup_31bf3856ad364e35_10.0.10240.16384_none_37955d2cf51e580f"
call :deleteSxSEntry "x86_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.10240.16384_none_7b2f0c80239d4a8e"
call :deleteSxSEntry "amd64_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.10240.16384_none_d74da803dbfabbc4"
call :deleteSxSEntry "amd64_microsoft-windows-onedrive-setup_31bf3856ad364e35_10.0.10240.16384_none_2d40b2dac0bd9614"
call :deleteSxSEntry "x86_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.10240.16515_none_7b31ae72239ac6fc"
call :deleteSxSEntry "amd64_microsoft-windows-settingsync-onedrive_31bf3856ad364e35_10.0.10240.16515_none_d75049f5dbf83832"

rem Oh look, it's in the Package store too
call :forceDeleteFile "%MOUNTDIR%\Windows\servicing\Packages\Microsoft-Windows-OneDrive-Setup-Package~31bf3856ad364e35~amd64~~10.0.10240.16384.cat"
call :forceDeleteFile "%MOUNTDIR%\Windows\servicing\Packages\Microsoft-Windows-OneDrive-Setup-Package~31bf3856ad364e35~amd64~~10.0.10240.16384.mum"

call :forceDeleteFile "%MOUNTDIR%\Windows\System32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\Microsoft-Windows-OneDrive-Setup-Package~31bf3856ad364e35~amd64~~10.0.10240.16384.cat"

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

call :deleteSxSEntry "amd64_microsoft-windows-diagtrack-internal_31bf3856ad364e35_10.0.10240.16384_none_fbeacf5f4a5a8f6c"
call :deleteSxSEntry "amd64_microsoft-windows-u..ed-telemetry-client_31bf3856ad364e35_10.0.10240.16384_none_a7f36176a199e892"
call :deleteSxSEntry "amd64_microsoft-windows-u..y-extension-windows_31bf3856ad364e35_10.0.10240.16384_none_42e5f4f134a65590"
call :deleteSxSEntry "amd64_microsoft-windows-u..ry-client.resources_31bf3856ad364e35_10.0.10240.16384_en-us_cdd0aa8ddd26a925"

goto :eof
ENDLOCAL

:scdmwappushservice
SETLOCAL
echo Removing dmwappushservice service...
echo.
reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SYSTEM
reg delete HKLM\_ltsb\ControlSet001\Services\dmwappushservice /f
reg unload HKLM\_ltsb

call :forceDeleteFile "%MOUNTDIR%\Windows\System32\dmwappushsvc.dll"
call :forceDeleteFile "%MOUNTDIR%\Windows\System32\en-US\dmwappushsvc.dll.mui"

call :deleteSxSEntry "amd64_microsoft-windows-d..gement-dmwappushsvc_31bf3856ad364e35_10.0.10240.16384_none_57b05e8b1cca2831"
call :deleteSxSEntry "amd64_microsoft-windows-d..appushsvc.resources_31bf3856ad364e35_10.0.10240.16384_en-us_043975468ba6f47a"

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

rem Disable WiFi Sense
reg add "HKLM\_ltsb\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d 0 /f
reg add "HKLM\_ltsb\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "value" /t REG_DWORD /d 0 /f

reg unload HKLM\_ltsb
goto :eof
ENDLOCAL

:killUpdates
SETLOCAL
echo Disabling Updates...
choice /m "ARE YOU SURE YOU REALLY WANT TO DO THIS?"
if ERRORLEVEL 2 goto :eof

rem Disable it
reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SOFTWARE
reg add "HKLM\_ltsb\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\_ltsb\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f
reg unload HKLM\_ltsb

rem Disable the service.
reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SYSTEM
reg add HKLM\_ltsb\ControlSet001\Services\wuauserv /v Start /t REG_DWORD /d 4 /f
reg unload HKLM\_ltsb

goto :eof
ENDLOCAL

:fixPhotoViewer
SETLOCAL

reg load HKLM\_ltsb %MOUNTDIR%\Windows\System32\config\SOFTWARE
reg import "%~dp0photoviewer.reg"
reg unload HKLM\_ltsb

goto :eof
ENDLOCAL

:deleteSxSEntry
SETLOCAL

call :forceDeleteFolder "%MOUNTDIR%\Windows\WinSxS\%~1"
call :forceDeleteFile "%MOUNTDIR%\Windows\WinSxS\Manifests\%~1.manifest"

goto :eof
ENDLOCAL

:forceDeleteFile
SETLOCAL
echo Deleting %~1
takeown /f "%~1" 2> nul > nul
icacls "%~1" /grant Everyone:F /q 2> nul > nul
del /q "%~1" 2> nul > nul
goto :eof
ENDLOCAL

:forceDeleteFolder
SETLOCAL
echo Deleting %~1
takeown /f "%~1" /r 2> nul > nul
icacls "%~1" /grant Everyone:F /q /t 2> nul > nul
rd /s /q "%~1" 2> nul > nul
goto :eof
ENDLOCAL

:end
