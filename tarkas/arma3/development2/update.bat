@echo off
cls
set PATH=%SCRIPTS_BASE_PATH%\arma3\development1
cd %PATH%

call config.bat

:CheckForInProgress
ECHO [INFO] Updater has started...
REM Timestamp
ECHO **********
date /t
time /t
ECHO **********

	ECHO [INFO] Downloading workshop items...
    %STEAM_BASE_PATH%\steamcmd.exe +login %STEAM_USERNAME% %STEAM_PASSWORD% +workshop_download_item 107410 333310405 +workshop_download_item 107410 450814997 +workshop_download_item 107410 843577117 +workshop_download_item 107410 508476583 +workshop_download_item 107410 843425103 +workshop_download_item 107410 1891346714 +workshop_download_item 107410 463939057 +workshop_download_item 107410 583496184 +workshop_download_item 107410 583544987 +workshop_download_item 107410 843593391 +workshop_download_item 107410 735566597 +workshop_download_item 107410 1537973181 +workshop_download_item 107410 1452435838 +workshop_download_item 107410 1368857262 +workshop_download_item 107410 1128256978 +workshop_download_item 107410 1696706969 +workshop_download_item 107410 498740884 +workshop_download_item 107410 708250744 +workshop_download_item 107410 751965892 +workshop_download_item 107410 773125288 +workshop_download_item 107410 773131200 +workshop_download_item 107410 884966711 +workshop_download_item 107410 820924072 +workshop_download_item 107410 1891343103 +workshop_download_item 107410 1891349162 +workshop_download_item 107410 721359761 +workshop_download_item 107410 620260972 +workshop_download_item 107410 723217262 +workshop_download_item 107410 861133494 +quit
    ECHO Downloading mods complete.
	REM Timestamp
	ECHO **********
	time /t
	ECHO **********

:WorkshopLoader
ECHO [INFO] Validating and Updating Arma 3 Installation...
REM %STEAM_BASE_PATH%\steamcmd.exe +login %STEAM_USERNAME% %STEAM_PASSWORD% +force_install_dir D:\gameservers\arma3\development1 +app_update 233780 -beta profiling -betapassword CautionSpecialProfilingAndTestingBranchArma3 validate +quit
%STEAM_BASE_PATH%\steamcmd.exe +login STEAM_USERNAME %STEAM_PASSWORD% +force_install_dir D:\gameservers\arma3\development1 +app_update 233780 validate +quit
REM Timestamp
ECHO **********
time /t
ECHO **********

ECHO [INFO] Starting sort.bat...
REM Call script to start moving keys and mods into correct directories
cd %PATH%
call sort.bat

ECHO [INFO] Inserting sensitive values...
call "%SCRIPTS_BASE_PATH%\utilities\replace.bat" "%PATH%\config\BattleEye\beserver_x64.cfg" "RCON_PASSWORD" %RCON_PASSWORD%
call "%SCRIPTS_BASE_PATH%\utilities\replace.bat" "%PATH%\config\BattleEye\beserver_x64.cfg" "RCON_PORT" %RCON_PORT%
call "%SCRIPTS_BASE_PATH%\utilities\replace.bat" "%PATH%\config\Admin\secretKey.sqf" "CIPHER_SECRET_KEY" %CIPHER_SECRET_KEY%
call "%SCRIPTS_BASE_PATH%\utilities\replace.bat" "%PATH%\config\server.cfg" "INGAME_PASSWORD" %INGAME_PASSWORD%
call "%SCRIPTS_BASE_PATH%\utilities\replace.bat" "%PATH%\config\server.cfg" "INGAME_ADMIN_PASSWORD" %INGAME_ADMIN_PASSWORD%

:EF
ECHO [INFO] Updater has finished.
REM Timestamp
ECHO **********
time /t
ECHO **********
ECHO [INFO] Exiting Updater...
timeout 2 >nul
net stop /y Arma3Dev2Updater
