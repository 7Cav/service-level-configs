$targetFolder = "D:\gameservers\arma3\mpmissions"
$fileList = "D:\scripts\utilities\DeleteMissions.txt"

Get-ChildItem -Path "$targetFolder\*" -Recurse -Include @(Get-Content $fileList) | Remove-Item -Verbose