@echo off

:Copybatch
ECHO [INFO] Starting Sorting of Files...
ECHO **********
ECHO [INFO] Mirroring workshop items to Dev 2 mods directories...
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\333310405" "%ARMA_BASE_PATH%\@ENH_MOVE" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\450814997" "%ARMA_BASE_PATH%\@CBA_A3" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\843577117" "%ARMA_BASE_PATH%\@RHS_USAF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\508476583" "%ARMA_BASE_PATH%\@TF47" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\843425103" "%ARMA_BASE_PATH%\@RHS_AFRF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1891346714" "%ARMA_BASE_PATH%\@USAF_MAIN" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\463939057" "%ARMA_BASE_PATH%\@ACE" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\583496184" "%ARMA_BASE_PATH%\@CUP_CORE" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\583544987" "%ARMA_BASE_PATH%\@CUP_MAPS" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\843593391" "%ARMA_BASE_PATH%\@RHS_GREF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\735566597" "%ARMA_BASE_PATH%\@PRJ_OPF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1537973181" "%ARMA_BASE_PATH%\@ANIZAY" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1452435838" "%ARMA_BASE_PATH%\@ESSEKER_FIXED" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1368857262" "%ARMA_BASE_PATH%\@RUHA" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1128256978" "%ARMA_BASE_PATH%\@CHER_REDUX" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1696706969" "%ARMA_BASE_PATH%\@7CAV_CBA" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\498740884" "%ARMA_BASE_PATH%\@SHK_UI" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\708250744" "%ARMA_BASE_PATH%\@ACEX" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\751965892" "%ARMA_BASE_PATH%\@ACRE" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\773125288" "%ARMA_BASE_PATH%\@ACE_USAF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\773131200" "%ARMA_BASE_PATH%\@ACE_AFRF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\884966711" "%ARMA_BASE_PATH%\@ACE_GREF" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\820924072" "%ARMA_BASE_PATH%\@BPK_CST" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1891343103" "%ARMA_BASE_PATH%\@USAF_FIGHTER" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\1891349162" %ARMA_BASE_PATH%\@USAF_UTIL" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\721359761" "%ARMA_BASE_PATH%\@VCOM_AI" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\620260972" "%ARMA_BASE_PATH%\@ALIVE" /mir
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\723217262" "%ARMA_BASE_PATH%\@ACHILLES" /mir

ECHO [INFO] Mirroring Optional workshop items to Dev 2...
REM Optional JSRS Mod
robocopy "%STEAM_BASE_PATH%\steamapps\workshop\content\107410\861133494" "%ARMA_BASE_PATH%\@JSRS" /mir

REM Delete all keys except for the arma 3 key, so we can copy in new ones from mods.
ECHO [INFO] removing all old keys from \key directory
cd %ARMA_BASE_PATH%\keys
attrib +r +s a3.bikey
del %ARMA_BASE_PATH%\keys\*.* /Q
attrib -r -s a3.bikey

ECHO [INFO] Copying new keys from mod folders to \keys...
robocopy "%ARMA_BASE_PATH%\@ENH_MOVE\Keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@CBA_A3\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@RHS_USAF\key"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@TF47\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@RHS_AFRF\key"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@USAF_MAIN\key"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ACE\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@CUP_CORE\Keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@CUP_MAPS\Keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@RHS_GREF\key"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@PRJ_OPF\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ANIZAY\Keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ESSEKER_FIXED\Keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@RUHA\Keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@CHER_REDUX\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@7CAV_CBA\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@SHK_UI\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ACEX\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ACRE\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@BPK_CST\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@USAF_FIGHTER\key"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@USAF_UTIL\key"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@VCOM_AI\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ALIVE\keys"      	%ARMA_BASE_PATH%\keys *.bikey
robocopy "%ARMA_BASE_PATH%\@ACHILLES\keys"		%ARMA_BASE_PATH%\keys *.bikey

REM Optional Mods
ECHO [INFO] Copying optional mod keys to \keys directory...
robocopy "%ARMA_BASE_PATH%\JSRS\keys"                    %ARMA_BASE_PATH%\keys *.bikey

REM B3 checks all new connections to the server, but when someone is unbanned in B3 it doesn't remove them from Arma 3's bans file.
REM So we first delete this file, people that are banned in B3 will be re-added when the first try to connect.
ECHO [INFO] Removing old bans
del /F /Q %SCRIPTS_BASE_PATH%\arma3\development1\config\BattlEye\bans.txt

ECHO [INFO] Removing old Zeus Script
del /F /Q %ARMA_BASE_PATH%\config\serverscripts\zeusserverscripts\tac2_zeus_guids.sqf

REM Move files from admin to zeusserverscripts.
ECHO [INFO] copying files from arma3\development1\config\admin to \zeusserverscripts
robocopy "%SCRIPTS_BASE_PATH%\arma3\development1\config\Admin"    		%ARMA_BASE_PATH%\serverscripts\zeusserverscripts

REM End of File
ECHO [INFO] Finished Sorting files.
