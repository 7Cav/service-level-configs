@set @a=0  /*

:: Fetch file
set "file=%~1"
goto :fileCheck
:fileCheck
if "%file%"=="" ECHO "no provided file"

:: Fetch old
set "old=%~2"
goto :oldCheck
:oldCheck
if "%old%"=="" ECHO "no provided string to replace"

:: Fetch new
set "new=%~3"
goto :newCheck
:newCheck
if "%new%"=="" ECHO "no provided string to replace WITH"

set InputFile="%file%"
set OutputFile="%file%"

cscript //nologo //E:JScript "%~F0" "%old%" "%new%" < "%InputFile%" > "%OutputFile%"

@goto :EOF */

WScript.Stdout.Write(WScript.Stdin.ReadAll().replace(WScript.Arguments(0), WScript.Arguments(1)));
