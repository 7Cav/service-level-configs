#Instance Configuration Development 2 Server
$config = "D:\config\development2\dev2.json"
#
$configJson = Get-Content -Raw -Path $config | ConvertFrom-Json
$instanceId = $configJson.server.env.SERVER_ID
$serverName = $configJson.server.env.SERVER_NAME
$modListJson = $configJson.mods
$serverModListJson = $configJson.servermods
$localModListJson = $configJson.localmods
$configDir = $configJson.server.env.ARMA_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$installDir = $configJson.server.env.STEAM_BASE_PATH
$installDirArmadirectory = $configJson.server.env.ARMA_BASE_PATH
$localModDir = $configJson.server.env.LOCAL_MOD_PATH
# This is populated by system environment for development servers.
# $steamUser = $configJson.server.env.STEAM_USERNAME
# $steamPass = $configJson.server.env.STEAM_PASSWORD
# Leave this block commented out unless using the json for steam login info.
$steamUser = $env:STEAM_USER
$steamPass = $env:STEAM_PASS
#Add server name from json to config path.
$configDir = "$configDir\$serverName"
$steamCMDdir += "steamcmd.exe"

#For purposes of updating no need to have seperate arrays for workshop mods in the script.
$modListJson = $modListJson += $serverModListJson

Write-Output "Update has started: $(Get-Date)"

#Stop Firedaemon Service
#net stop $instanceName

#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir "+$installDir+" "
#download each item in steamcmd using the app id in the mod list array
foreach($item in $modListJson) 
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
foreach($item in $modListJson) 
{
   $id = $item.app
   $name = $item.name

   copy-item $installDirWorkshop\$id\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirWorkshop\$id\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   copy-item $installDirWorkshop\$id\key\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirWorkshop\$id\key\*.bikey $installDirArmadirectory\keys\ -force -recurse

   New-Item -Path $installDirArmadirectory\$name -ItemType SymbolicLink -Value $installDirWorkshop\$id

}

#local mod retreival
foreach($item in $localModListJson)
{
   $name = $item.name
   $path = $localModDir

   copy-item $path\$name $installDirArmadirectory\ -force -recurse
   Write-Output copy-item $path\$name $installDirArmadirectory -force -recurse
   copy-item $installDirArmadirectory\$name\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirArmadirectory\$name\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   copy-item $installDirArmadirectory\$name\key\*.bikey $installDirArmadirectory\key\ -force -recurse
   Write-Output copy-item $installDirArmadirectory\$name\key\*.bikey $installDirArmadirectory\key\ -force -recurse
}

# To Do,
# Add recursive copying of server side scripts
# Add automatic unlocks for mpmissions for backups and insession updating
#

#Removing logs after update
#Remove-Item $configDir\*.rpt 
#Remove-Item $configDir\*.log 
#Write-Output Remove-Item $configDir\*.rpt 
#Write-Output Remove-Item $configDir\*.log 

Write-Output "Update has finished: $(Get-Date) for $serverName"

#Start Firedaemon Service
#net start $instanceName
