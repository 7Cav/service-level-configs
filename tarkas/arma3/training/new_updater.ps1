#Instance Configuration
$instanceName = "Arma3Training1" #Firedaemon shortname
$serverName = "training" #name of folder for arma 3 installation
$modListJson = "D:\scripts\arma\training\training.json" #path to mod list json
$configDir = "D:\config\" #path to config directory
#Do not edit below this line
$steamCMDdir = "D:\steam\steamcmd.exe" #path to steamcmd executable
$installDirWorkshop = "D:\steam\steamapps\workshop\content\107410" #path to workshop directory
$installDir = "D:\gameservers\"+$serverName
$installDirArmadirectory = $installDir
$steamUser = $Env:STEAM_USER #Env var for steam user name
$steamPass = $Env:STEAM_PASS #Env var for steam password

Write-Output "Update has started: $(Get-Date)"

#Stop Firedaemon Service
#net stop $instanceName

#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir "+$installDir+" "
#Create powershell array from the mod list json file
$json = Get-Content -Raw -Path $modListJson | ConvertFrom-Json
#download each item in steamcmd using the app id in the mod list array
foreach($item in $json) 
{
	$id = $item.app
	$argumentListArray += "+workshop_download_item 107410 $id "
}   
#update and validate arma 3 base installation
$argumentListArray += "+force_install_dir $installDirArmadirectory +app_update 233780 validate +quit"
Write-Output $argumentListArray

Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
Write-Output Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
#copying keys
foreach($item in $json.mods) 
{
   $id = $item.app
   $name = $item.name

   copy-item $installDirWorkshop\$id\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirWorkshop\$id\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   copy-item $installDirWorkshop\$id\key\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirWorkshop\$id\key\*.bikey $installDirArmadirectory\keys\ -force -recurse

   New-Item -Path $installDirArmadirectory\$name -ItemType SymbolicLink -Value $installDirWorkshop\$id

}

#Removing logs after update
Remove-Item $configDir+\training1\*.rpt 
Remove-Item $configDir+\training1\*.log 
Write-Output Remove-Item $configDir+\training1\*.rpt 
Write-Output Remove-Item $configDir+\training1\*.log 
Remove-Item $configDir+\training2\*.rpt 
Remove-Item $configDir+\training2\*.log
Write-Output Remove-Item $configDir+\training2\*.rpt 
Write-Output Remove-Item $configDir+\training2\*.log 
Remove-Item $configDir+\training3\*.rpt 
Remove-Item $configDir+\training3\*.log 
Write-Output Remove-Item $configDir+\training3\*.rpt 
Write-Output Remove-Item $configDir+\training3\*.log 
Remove-Item $configDir+\training4\*.rpt 
Remove-Item $configDir+\training4\*.log
Write-Output Remove-Item $configDir+\training4\*.rpt 
Write-Output Remove-Item $configDir+\training4\*.log

Write-Output "Update has finished: $(Get-Date)"

#Start Firedaemon Service
#net start $instanceName