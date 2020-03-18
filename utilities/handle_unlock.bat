@echo off
Setlocal
REM ~~~~~~~~~~~~~~~~~~ HANDLE UNLOCK ~~~~~~~~~~~~~~~~~~
REM      Author: Sweetwater.I
REM      Created on March 18, 2020
REM      7thCavalry.us
REM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ECHO --------------------------------------------------
ECHO          UNLOCKING .PBO Files                    
ECHO --------------------------------------------------
ECHO          Directory: "%~dp0"
ECHO --------------------------------------------------

set EXT=pbo
set HANDLE_PATH=D:\utils\Handle


	for /f "eol=: delims=" %%F in ('dir /b /o-d "%~dp0\*.%EXT%"') do (
	cls
	echo "%~dp0\%%F"

	for /F "tokens=3,6 delims=: " %%I IN ('"%HANDLE_PATH%\handle.exe %%F"') DO "%HANDLE_PATH%\handle.exe" -c %%J -y -p %%I
	)
)
exit