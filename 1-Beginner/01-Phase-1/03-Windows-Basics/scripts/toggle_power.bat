@echo off
:: Set the GUIDs into variables
set "ULTIMATE=e9a42b02-d5df-448d-aa00-03f14749eb61"
set "SAVER=a1841308-3541-4fab-bc81-f71556f20b4a"

:: Get the GUID of the currently active plan
for /f "tokens=4" %%a in ('powercfg -getactivescheme') do set "current=%%a"

:: Logic to toggle
if "%current%"=="%ULTIMATE%" (
    powercfg -setactive %SAVER%
    echo Switched to [Power Saver]
) else (
    powercfg -setactive %ULTIMATE%
    echo Switched to [Ultimate Performance]
)

pause