#Instance Configuration training Server
$configPath = 'https://raw.githubusercontent.com/7Cav/service-level-configs/master/tarkas/arma3/training/test.json'
$configJson = (New-Object System.Net.WebClient).DownloadString($configPath) | ConvertFrom-Json
#
$instanceId = $configJson.server.env.SERVER_ID
$serverName = $configJson.server.env.SERVER_NAME
$modListJson = $configJson.mods
$scripts = $configJson.server.env.SCRIPTS_REL_PATH
$configDir = $configJson.server.env.ARMA_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$installDir = $configJson.server.env.STEAM_BASE_PATH
$installDirArmadirectory = $configJson.server.env.ARMA_BASE_PATH
$localModDir = $configJson.server.env.LOCAL_MOD_PATH
$steamUser = $env:STEAM_USER
$steamPass = $env:STEAM_PASS
# Join Paths and other
$configDir = "$configDir\$serverName"
$steamCMDdir += "steamcmd.exe"
$serverScripts = "$installDirArmadirectory\$scripts"

Write-Output "Update has started: $(Get-Date) for Service $instanceId - $serverName"

#Stop Firedaemon Service
#net stop $instanceId

#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir "+$installDir+" "
#download each item in steamcmd using the app id in the mod list array
foreach($item in $modListJson) 
{
    $id = $item.app
    if ($id -ne "")
    {
    $argumentListArray += "+workshop_download_item 107410 $id "
    }
}   
#update and validate arma 3 base installation
$argumentListArray += "+force_install_dir $installDirArmadirectory +app_update 233780 validate +quit"
Write-Output $argumentListArray

Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
Write-Output Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
#copying keys and mods to dir from workshop
foreach($item in $modListJson) 
{
   $id = $item.app
   $name = $item.name
   $path = $localModDir
   if ($id -ne "")
   {
      New-Item -ItemType Junction -Path "$installDirArmadirectory\$name" -Target $installDirWorkshop\$id
      Write-Output New-Item -ItemType Junction -Path "$installDirArmadirectory\$name" -Target $installDirWorkshop\$id

      copy-item $installDirWorkshop\$id\[Kk][eE][yYsS]\*.bikey $installDirArmadirectory\keys\ -force -recurse
      Write-Output $installDirWorkshop\$id\[Kk][eE][yYsS]\*.bikey $installDirArmadirectory\keys\ -force -recurse
   }
   else
   {
      New-Item -ItemType Junction -Path "$installDirArmadirectory\$name" -Target "$path\$name"
      Write-Output New-Item -ItemType Junction -Path "$installDirArmadirectory\$name" -Target "$path\$name"

      copy-item $installDirArmadirectory\$name\[Kk][eE][yYsS]\*.bikey $installDirArmadirectory\keys\ -force -recurse
      Write-Output copy-item $installDirArmadirectory\$name\[Kk][eE][yYsS]\*.bikey $installDirArmadirectory\keys\ -force -recurse
   }
}

Write-Output "$serverScripts has yet to be assigned in the script"
# To Do,
# Add recursive copying of server side scripts
# Add automatic unlocks for mpmissions for backups and insession updating
#

#Removing logs after update
Remove-Item $configDir\*.rpt 
Remove-Item $configDir\*.log 
Write-Output Remove-Item $configDir\*.rpt 
Write-Output Remove-Item $configDir\*.log 

Write-Output "Update has finished: $(Get-Date) for $serverName"

#Start Firedaemon Service
#net start $instanceId
exit